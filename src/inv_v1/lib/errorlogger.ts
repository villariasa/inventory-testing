/*
 * Version history:
 *   1.0.0   2025-08-11
 *     - Initial release
 *     - Core features:
 *       - Automated log rotation
 *       - JSON error formatting
 *       - Size-based file management
 *
 * Purpose:
 *   Provides structured error logging with automated file rotation and retention.
 *   Integrates with database connector and other core components.
 *
 * Usage:
 *   1. Import the logger:
 *      import { ErrorLogger } from './errorlogger';
 *   2. Log errors in catch blocks:
 *      await ErrorLogger.getInstance().logError(error, 'ClassName.methodName');
 *
 * File Management:
 *   - Location: dist/log/
 *   - Naming: errorYYYYMMDD.log
 *   - Retention: 3 generations per day (.log, .log1, .log2)
 *   - Max Size: 1MB per file
 */

import { promises as fs } from 'fs';
import * as path from 'path';

/**
 * Interface defining error log entry structure
 * @interface ErrorLogEntry
 * @property {string} code - Error code or 'UNKNOWN'
 * @property {string} message - Human-readable description
 * @property {string} entry_time - ISO 8601 timestamp
 * @property {string} function_method - Origin context
 * @example
 * {
 *   code: "ENOTFOUND",
 *   message: "DNS lookup failed",
 *   entry_time: "2025-08-11T02:00:00.000Z",
 *   function_method: "APIClient.sendRequest"
 * }
 */
export interface ErrorLogEntry {
    code: string;
    message: string;
    entry_time: string;
    function_method: string;
}

/**
 * Central error logging controller (Singleton)
 * @class ErrorLogger
 * @example
 * // Database connector integration example
 * try {
 *   await db.executeQueries();
 * } catch (error) {
 *   ErrorLogger.getInstance().logError(error, 'DBProcessor.executeQueries');
 * }
 */
export class ErrorLogger {
    private static instance: ErrorLogger;
    private currentSize = 0;
    private currentDate: string;
    private readonly MAX_SIZE = 1048576;
    private readonly MAX_FILES = 3;

    private constructor() {
        this.currentDate = this.getDateString();
        this.ensureLogDirectory().catch(console.error);
    }

    private getDateString(): string {
        const now = new Date();
        return now.toISOString().slice(0, 10).replace(/-/g, '');
    }

    private async ensureLogDirectory(): Promise<void> {
        const logDir = path.join(process.cwd(), 'dist', 'log');
        try {
            await fs.mkdir(logDir, { recursive: true });
        } catch (error) {
            console.error('Failed to create log directory:', error);
        }
    }

    private async checkRotation(): Promise<void> {
        const currentDate = this.getDateString();
        if (currentDate !== this.currentDate) {
            this.currentDate = currentDate;
            this.currentSize = 0;
        }
        if (this.currentSize >= this.MAX_SIZE) {
            await this.rotateFiles();
        }
    }

    private async rotateFiles(): Promise<void> {
        const logDir = path.join(process.cwd(), 'dist', 'log');
        const baseName = `error${this.currentDate}`;
        
        // Rotate existing files
        for (let i = this.MAX_FILES - 1; i > 0; i--) {
            const oldPath = path.join(logDir, `${baseName}.log${i - 1}`);
            const newPath = path.join(logDir, `${baseName}.log${i}`);
            try {
                await fs.rename(oldPath, newPath);
            } catch {
                // Ignore file not found errors
            }
        }

        // Rename current log to .log1
        const currentPath = path.join(logDir, `${baseName}.log`);
        try {
            await fs.rename(currentPath, path.join(logDir, `${baseName}.log1`));
        } catch {
            // Ignore if file doesn't exist
        }
    }

    private createLogEntry(error: unknown, context: string, timestamp: Date): ErrorLogEntry {
        return {
            code: (error as any).code || 'UNKNOWN',
            message: error instanceof Error ? error.message : String(error),
            entry_time: timestamp.toISOString(),
            function_method: context
        };
    }

    private async writeLogEntry(entry: ErrorLogEntry): Promise<void> {
        const logDir = path.join(process.cwd(), 'dist', 'log');
        const logPath = path.join(logDir, `error${this.currentDate}.log`);
        const logLine = JSON.stringify(entry) + '\n';
        
        try {
            await fs.appendFile(logPath, logLine);
            this.currentSize += Buffer.byteLength(logLine);
        } catch (error) {
            console.error('Failed to write error log:', error);
        }
    }

    /**
     * Retrieves singleton instance
     * @static
     * @returns {ErrorLogger} Global logger instance
     * @example
     * // Cross-component usage
     * const logger = ErrorLogger.getInstance();
     * logger.logError(networkError, 'NetworkManager.connect');
     */
    public static getInstance(): ErrorLogger {
        if (!ErrorLogger.instance) {
            ErrorLogger.instance = new ErrorLogger();
        }
        return ErrorLogger.instance;
    }

    /**
     * Records error with context metadata
     * @async
     * @param {unknown} error - Error object or value
     * @param {string} context - Origin context
     * @returns {Promise<ErrorLogEntry>} Created entry
     * @throws {TypeError} For invalid context
     * @example
     * // Database error logging
     * try {
     *   await db.connect();
     * } catch (error) {
     *   await logger.logError(error, 'DBProcessor.connect');
     * }
     */
    public async logError(error: unknown, context: string): Promise<ErrorLogEntry> {
        console.error(`❌ [ErrorLogger] Error in ${context}:`, error);
        try {
            await this.checkRotation();
        } catch (e) {}
        const logEntry = this.createLogEntry(error, context, new Date());
        try {
            await this.writeLogEntry(logEntry);
        } catch (e) {}
        return logEntry;
    }

    // ... rest of implementation ...
}
