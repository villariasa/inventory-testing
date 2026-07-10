import * as mysql from 'mysql2/promise';
import type { Connection, RowDataPacket } from 'mysql2/promise';
import { ErrorLogger } from './errorlogger.js';

// Get the singleton instance of the ErrorLogger
const errorLogger = ErrorLogger.getInstance();

/*
 * Version history:
 * 1.0.0	2025 july 01
 *	1.0.1	2025 july 03
 *		modifications:
 *			checking of number of parameters passed when executing a `SELECT` query
 *			from if ('insertId' in header) to if ('insertId' in header && header.insertId > 0) 
 *	1.0.2	2025 august 11
 *		modifications:
 *			include error handling and checking of types
 *	1.0.3	2025 august 11
 *		modifications:
 *			Integrated ErrorLogger for all error handling
 *
 *  1.0.4	2025 august 13
 *		modifications:
 *			added term `CALL` to extract query result set
 *
 * Purpose:
 * common interface for JS mysql connector, at the same time providing a
 * consistent on query format
 *
 * Usage:
 * to import
 * import { DBProcessor } from './dbconn.js' // assumption the JS file is located
 * // on the same folder or directory
 *					  // of the importing JS/TS codes file
 *
 * declaration to create instance of this class
 * const <varName> = new DBProcessor(`<Host or IP address>`, `<DB User>`, `<Password>`);
 *
 *
 * Properties:
 * dbHost		will contain the database Host or IP address
 * dbPort		the designated port number of the database service, defaults to 3306 when left empty or unassigned
 *	dbUser		the MySQL user given access to the target database or databases
 *	dbPassword	the MySQL user password to be able to access the target database or databases
 *
 *	queries[]	this contains the queued query commands
 *
 *	queryResults[]	is an array containing result set corresponding to each query command
 *			with INSERT this will contain the last inserted ID
 *			with UPDATE/DELETE this will contain the number of affected rows
 *			with SELECT this will contain the datatable 
 *
 * Methods:
 * setQueries(`<SQL command>`,[][])
 * this will create a query pair of SQL command and its corresponding parameters (optional).
 * a user can create a multiple query pairs and it will be carried out in order of
 * sequence the query pairs are added.
 *
 * example of usage:
 * single query pair
 * await <varName>.setQueries(`INSERT testdb.clients (firstname, lastname) VALUES (?, ?)`, [[`peter`, `santos`]]);
 *
 * mutilple queries
 * await <varName>.setQueries(`INSERT testdb.clients (firstname, lastname) VALUES (?, ?)`, [[`peter`, `santos`], [`maria`, `motilaw`]]);
 * await <varName>.setQueries(`SELECT lastname FROM testdb.clients`);
 * await <varName>.setQueries(`INSERT testdb.clients SET lastname = 'moreno', firstname = 'alex'`);
 *
 * executeQueries()
 * this will execute all queued queries. return value boolean.
 * will return `true` if all queued queries are successfully carried out.
 * will return `false` it queued queries failed to be carried out.
 *
 * when queued queries are successfully carried out, use can access results for each corresponding
 * query from property queryResults[i]
 *
 * example of usage:
 * await <varName>.executeQueries()
 * *
 *
*/

// NOTE: type and interface definitions must be declared
// 		outside the class definition 

// define a 2 dimensional array type
type QueryParamSet = (string | number | Date | null)[][];

// define a class that will contain the query command
// and passed parameters
interface QueryJob {
	queryCommand: string | string[];
        queryParms?: QueryParamSet;
	};

export class DBProcessor {
	public dbHost: string;
	public dbPort: number;
	public dbUser: string;
	public dbPassword: string;
	public dbName?: string;

	private dbConnection: Connection | undefined;
	
	// initialized below query related arrays as empty
	public queryResults: (RowDataPacket[] | number)[] = [];
	public queries: QueryJob[] = []; 

	// will execute queries from array queryCommands
	public async executeQueries(): Promise<boolean> {
		let returnValue: boolean = true;

		const connected = await this.createDatabaseConnection();
		if (connected && this.dbConnection) {
		
			try {
				let result: any;
				let dbParm: (string | number | Date | null)[] | undefined = undefined; // for single array parameter

				this.queryResults.length = 0;
				for (const query of this.queries) {

					if (Array.isArray(query.queryCommand)) {
						let finalResult: RowDataPacket[] | undefined;
						let lastInsertId: number = 0;
						let firstInsertId: number = 0;

						for (let i = 0; i < query.queryCommand.length; i++) {
							// Substitute JS-tracked ID placeholders before executing
							let cmd = query.queryCommand[i];
							if (lastInsertId > 0) {
								cmd = cmd.replace(/__LAST_INSERT_ID__/g, String(lastInsertId));
							}
							if (firstInsertId > 0) {
								cmd = cmd.replace(/__FIRST_INSERT_ID__/g, String(firstInsertId));
							}

							const trimmed = cmd.trim().toLowerCase();
							if (trimmed.startsWith('select') || trimmed.startsWith('call')) {
								const res = await this.getRecords(cmd);
								if (i === query.queryCommand.length - 1) {
									finalResult = res;
								}
							} else {
								const [res] = await this.dbConnection.query(cmd);
								const header = res as unknown as mysql.ResultSetHeader;
								if ('insertId' in header && header.insertId > 0) {
									lastInsertId = header.insertId;
									if (firstInsertId === 0) {
										firstInsertId = header.insertId;
									}
								}
								if (i === query.queryCommand.length - 1) {
									finalResult = [header as unknown as RowDataPacket];
								}
							}
						}
						this.queryResults.push(finalResult || []);
					} else {
						if (query.queryCommand.toLowerCase().startsWith('select') || query.queryCommand.toLowerCase().startsWith('call')) {
							if (query.queryCommand.includes('; SELECT @lastPostResult AS response')) {
								const parts = query.queryCommand.split('; SELECT @lastPostResult AS response');
								const firstCommand = parts[0].trim();
								const secondCommand = ('SELECT @lastPostResult AS response' + (parts[1] || '')).trim();
								
								if (query.queryParms && query.queryParms.length === 1) {
									dbParm = query.queryParms[0];
									await this.getRecords(firstCommand, dbParm);
								} else if (query.queryParms && query.queryParms.length > 1) {
									await this.getRecords(firstCommand, query.queryParms.flat());
								} else {
									await this.getRecords(firstCommand);
								}
								
								const selectResult = await this.getRecords(secondCommand);
								this.queryResults.push(selectResult || []);
							} else {
								if (query.queryParms && query.queryParms.length === 1) {
									dbParm = query.queryParms[0];
									const result = await this.getRecords(query.queryCommand, dbParm);
									this.queryResults.push(result || []);
								} else if (query.queryParms && query.queryParms.length > 1) {
									const result = await this.getRecords(query.queryCommand, query.queryParms.flat());
									this.queryResults.push(result || []);
								} else {
									const result = await this.getRecords(query.queryCommand);
									this.queryResults.push(result || []);
								}
							}
						} else {
							if (query.queryParms && query.queryParms.length === 1) {
								dbParm = query.queryParms[0];
								[result] = await this.dbConnection.query(query.queryCommand, dbParm);
							} else if (query.queryParms && query.queryParms.length > 1) {
								// the .flat() function will convert the 2D array into 1D
								// mysql query can only accept series of 1D array as parameters
								[result] = await this.dbConnection.query(query.queryCommand, query.queryParms.flat());
							} else {
								[result] = await this.dbConnection.query(query.queryCommand);
							}

							const header = result as unknown as mysql.ResultSetHeader;

							if ('insertId' in header && header.insertId > 0) {
								this.queryResults.push(header.insertId);
							} else {
								this.queryResults.push(header.affectedRows);
							};
						};
					}
				}

				this.queries.length = 0;
			} catch (error) {
				// MODIFIED: Replaced console.log with a call to the error logger.
				await errorLogger.logError(error, 'DBProcessor.executeQueries');
				returnValue = false;
			} finally {
				await this.dbConnection.end();
                this.dbConnection = undefined;
			}
		}
		return returnValue;
	}

	// will add series of query commands and corresponding parameters (if any)
	public async setQueries(sqlCommand: string | string[], params?: QueryParamSet): Promise<boolean> {
		let returnValue = true;

		try {
			// Validate null parameters
			if (params) {
				for (const paramSet of params) {
					if (paramSet.some(p => p === null)) {
						console.warn('Null parameters detected - ensure database schema allows NULL values');
						break;
					}
				}
			}

			if (this.queryResults.length > 0) {
				this.queryResults.length = 0;
			}

			if (Array.isArray(sqlCommand)) {
				this.queries.push({
					queryCommand: sqlCommand.map(cmd => cmd.trimStart()),
					queryParms: params?.map(p => p.map(v => v === null ? null : v)) as QueryParamSet
				});
			} else {
				this.queries.push({
					queryCommand: sqlCommand.trimStart(),
					queryParms: params?.map(p => p.map(v => v === null ? null : v)) as QueryParamSet
				});
			}
		} catch (error) {
			// MODIFIED: Replaced console.log with a call to the error logger.
			await errorLogger.logError(error, 'DBProcessor.setQueries');
			returnValue = false;
		};
		return returnValue;
	}

	// will clear query related arrays
	private async clearQueries(): Promise<boolean> {
        let returnValue: boolean = true;

        try {
			this.queries.length = 0;
        } catch (error) {
			// MODIFIED: Replaced console.log with a call to the error logger.
			await errorLogger.logError(error, 'DBProcessor.clearQueries');
			returnValue = false;
        };
        return returnValue;
    }

	// for extracting records, this will return a datatable
	private async getRecords(queryCommand: string, params: (string | number | Date | null)[] = []): Promise<RowDataPacket[] | undefined> {

		let closeConnectionAfterwards: boolean = false;
		let returnValue: RowDataPacket[] | undefined;
		let continueProcess: boolean = true;


		try {
			if (this.dbConnection === undefined) {
            	const connected = await this.createDatabaseConnection();
            	if (!connected || !this.dbConnection) {
                	continueProcess = false;
            	} else {
                	closeConnectionAfterwards = true;
            	}
            };

			if (continueProcess) {
				console.log("Executing Query:", queryCommand);
				// Execute the query using the established connection.
                // Use destructuring `[rows]` to get the data table from the result tuple.
                const [rows] = (params && params.length > 0)
                  ? await this.dbConnection!.query(queryCommand, params)
                  : await this.dbConnection!.query(queryCommand);

                 // `rows` will be a RowDataPacket[] for SELECT statements.
                 if (Array.isArray(rows) && rows.length > 0 && Array.isArray(rows[rows.length - 1])) {
                     returnValue = rows[rows.length - 1] as RowDataPacket[];
                 } else {
                     returnValue = rows as RowDataPacket[];
                 }
 			}
		} catch (error) {
			// MODIFIED: Replaced console.log with a call to the error logger.
            await errorLogger.logError(error, 'DBProcessor.getRecords');
		} finally {
			if (closeConnectionAfterwards) {
    			await this.dbConnection?.end();
    			this.dbConnection = undefined;
    		}	
		}
		return returnValue || [];
	};

	private async createDatabaseConnection(): Promise<boolean> {
		let returnValue: boolean = true;

		try {
			const dbConfig: any = {
                host: this.dbHost,
                port: this.dbPort,
                user: this.dbUser,
                password: this.dbPassword,
                multipleStatements: true,
                disableEval: true
			};
			if (!this.dbHost.includes('.hyperdrive.local')) {
				dbConfig.ssl = {};
			}
			if (this.dbName) {
				dbConfig.database = this.dbName;
			}

			this.dbConnection = await mysql.createConnection(dbConfig);
		} catch (error) {
			// MODIFIED: Simplified error handling to directly use the logger.
			await errorLogger.logError(error, 'DBProcessor.createDatabaseConnection');
			returnValue = false;
		} finally {
			return returnValue
		}
	};

	constructor(
		host: string,
		user: string,
		passwd: string,
		port?: number,
		database?: string,
		public readonly connectTimeout: number = 10000
	) {
		this.dbHost = host;
		this.dbPort = port || 3306;
		this.dbUser = user;
		this.dbPassword = passwd;
		this.dbName = database;
	}
}
