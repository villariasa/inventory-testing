// Centralized Database Connection Factory
// Version: 1.0
// Date: 2026-01-30
// Ensures all database connections use the same instance as defined in .env file

import { DBProcessor } from './dbconn.js';
import { ErrorLogger } from './errorlogger.js';

const errorLogger = ErrorLogger.getInstance();

/**
 * Database configuration interface
 */
interface DatabaseConfig {
    host: string;
    user: string;
    password: string;
    port: number;
    database: string;
}

/**
 * Centralized database connection factory
 * Ensures all connections use the same configuration from .env file
 */
export class DatabaseFactory {
    private static instance: DatabaseFactory;
    private config!: DatabaseConfig;

    private constructor() {
        // Configuration will be loaded lazily when first needed
    }

    /**
     * Get singleton instance of DatabaseFactory
     */
    public static getInstance(): DatabaseFactory {
        if (!DatabaseFactory.instance) {
            DatabaseFactory.instance = new DatabaseFactory();
        }
        return DatabaseFactory.instance;
    }

    /**
     * Load database configuration from environment variables
     */
    private loadConfiguration(): void {
        // Validate required environment variables
        const requiredVars = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_PORT', 'DB_NAME'];
        const missingVars = requiredVars.filter(varName => !process.env[varName]);
        
        if (missingVars.length > 0) {
            console.error('❌ Database Factory Error: Missing environment variables');
            console.error(`Missing: ${missingVars.join(', ')}`);
            console.error('🔧 Please ensure your .env file contains all required database credentials');
            throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
        }

        this.config = {
            host: process.env.DB_HOST!,
            user: process.env.DB_USER!,
            password: process.env.DB_PASSWORD!,
            port: parseInt(process.env.DB_PORT!),
            database: process.env.DB_NAME!
        };

        // Log configuration (without password) for debugging
        console.log(`🔧 Database Factory initialized with: ${this.config.host}:${this.config.port}/${this.config.database}`);
    }

    /**
     * Create a new database processor instance with standardized configuration
     */
    public createDBProcessor(): DBProcessor {
        // Load configuration if not already loaded
        if (!this.config) {
            this.loadConfiguration();
        }

        const dbProcessor = new DBProcessor(
            this.config.host,
            this.config.user,
            this.config.password,
            this.config.port,
            this.config.database
        );

        console.log(`📊 Created DBProcessor: ${this.config.host}:${this.config.port}/${this.config.database}`);
        return dbProcessor;
    }

    /**
     * Get current database configuration (without password)
     */
    public getConfig(): Omit<DatabaseConfig, 'password'> {
        // Load configuration if not already loaded
        if (!this.config) {
            this.loadConfiguration();
        }

        return {
            host: this.config.host,
            user: this.config.user,
            port: this.config.port,
            database: this.config.database
        };
    }

    /**
     * Validate database connection by performing a test query
     */
    public async validateConnection(): Promise<{ success: boolean; error?: string; database?: string }> {
        try {
            // Load configuration if not already loaded
            if (!this.config) {
                this.loadConfiguration();
            }

            const testDB = this.createDBProcessor();
            
            // Test connection and verify we're connected to the correct database
            await testDB.setQueries('SELECT DATABASE() as current_database, CONNECTION_ID() as connection_id');
            const result = await testDB.executeQueries();
            
            if (result && testDB.queryResults[0] && Array.isArray(testDB.queryResults[0]) && testDB.queryResults[0][0]) {
                const dbInfo = (testDB.queryResults[0] as any[])[0] as any;
                const currentDatabase = dbInfo.current_database;
                
                if (currentDatabase !== this.config.database) {
                    return {
                        success: false,
                        error: `Connected to wrong database: ${currentDatabase}, expected: ${this.config.database}`
                    };
                }
                
                console.log(`✅ Database connection validated: ${currentDatabase} (Connection ID: ${dbInfo.connection_id})`);
                return {
                    success: true,
                    database: currentDatabase
                };
            }
            
            return {
                success: false,
                error: 'Failed to get database connection info'
            };
        } catch (error) {
            await errorLogger.logError(error, 'DatabaseFactory.validateConnection');
            return {
                success: false,
                error: (error as Error).message
            };
        }
    }

    /**
     * Force reload configuration from environment variables
     * Useful for testing or configuration changes
     */
    public reloadConfiguration(): void {
        this.loadConfiguration();
        console.log('🔄 Database Factory configuration reloaded');
    }
}

/**
 * Convenience function to get a standardized database processor
 * This should be used instead of manually creating DBProcessor instances
 */
export function createStandardDBProcessor(): DBProcessor {
    return DatabaseFactory.getInstance().createDBProcessor();
}

/**
 * Convenience function to validate database connectivity
 */
export async function validateDatabaseConnection(): Promise<{ success: boolean; error?: string; database?: string }> {
    return await DatabaseFactory.getInstance().validateConnection();
}
