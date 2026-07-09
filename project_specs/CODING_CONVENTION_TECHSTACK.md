# CODING CONVENTION

## Technical Stack
- **Framework**: HONO
- **Database**: MariaDB
- **Language**: TypeScript (ECMAScript Modules)
- **Validation**: Zod
- **Documentation**: OpenAPI/Swagger
- **Authentication**: JWT
- **Testing**: Jest + Supertest
- **Front-end**: Vanilla HTML, JS, CSS

**MANDATORY** make sure to install and install stable frameworks and libraries compatible with the existing and installed `Node JS` version
**MANDATORY** adhere strictly to the provided `Technical Stack`
**MANDATORY** when installing libraries outside the specified in `Technical Stack` ask for confirmation and approval

## Directory Structure Convention
- `src/acctg_v1/routes` - All route definitions
- `src/acctg_v1/handlers` - All request handlers
- `src/acctg_v1/queries` - All MariaDB/MySQL string queries
- `src/acctg_v1/schemas` - All Zod validation schemas
- `src/acctg_v1/interfaces` - All TypeScript interfaces
- `src/acctg_v1/utils` - All utility functions
- `src/acctg_v1/lib` - Common and shared libraries (includes existing dbconn.ts, errorlogger.ts)
- `src/acctg_v1/cli` - command line interface implementation
- `src/ui_test` - this will contain all TEST front-end related files implementations (i.e. HTML, JS)

## Coding Rules Compliance:
- **MANDATORY** DEFAULT ALWAYS READ `project_specs/REQUIREMENTS.md` or user specified specs file
- **MANDATORY** NEVER START OR EXECUTE CODING OR DEBUGGING WITHOUT THE FILE `project_progress/TASKS_BREAKDOWN_CHECKLIST.md` or user specified task checklist file
- **MANDATORY** WHEN FILE `project_progress/PROJECT_TRACKER.md` EXISTS or user specified project tracker file, resume activity to the specified **Next Task** 
- **MANDATORY** ALWAYS EVALUATE Typescript CODES WITH `eslint`
- **MANDATORY** Single exit point per function (`return` statement only after try...catch or at end)
- Maximum 800 lines per file
- TypeScript strict mode enabled
- ECMAScript modules throughout
- **MANDATORY** Use exclusively 'POST` method only, when there is no required JSON body parameter, implement endpoint to accept an empty JSON body parameter: `{ }`
- **MANDATORY** STANDARD SERVICE RESPONSE FORMAT:

    ```
    {
        "success": <boolean>,
        "http_code": <number>,
        "message": <string>,
        "data": <JSON object>
    }
    ```

- **MANDATORY** WHEN capturing response from database stored procedure, the format of the response from the database stored procedure:

    ```
    {
        "success": <boolean>,
        "message" <string>,
        "json_data": <JSON object>
    }
    ```

- **IMPORTANT** **MANDATORY** STORED PROCEDURE RESULT UNWRAPPING — mysql2/promise returns `CALL` statement results as a nested array: `[[data_rows...], OkPacket]`. The handler must unwrap this correctly before accessing the row and decoding the SP envelope. The standard implementation pattern for all SP-backed handlers is:

    ```typescript
    function parseSpEnvelope(firstVal: unknown): { success: boolean; message: string; json_data: unknown } | null {
      if (firstVal === null || firstVal === undefined) return null;
      let raw: unknown = firstVal;
      if (Buffer.isBuffer(firstVal)) {
        raw = (firstVal as Buffer).toString('utf8');
      } else if (
        typeof firstVal === 'object' && firstVal !== null &&
        (firstVal as Record<string, unknown>).type === 'Buffer' &&
        Array.isArray((firstVal as Record<string, unknown>).data)
      ) {
        raw = Buffer.from((firstVal as { type: string; data: number[] }).data).toString('utf8');
      }
      const parsed = (typeof raw === 'string' ? JSON.parse(raw) : raw) as { success: boolean; message: string; json_data: unknown };
      if (typeof parsed.json_data === 'string') {
        try { parsed.json_data = JSON.parse(parsed.json_data); } catch { /* leave as-is */ }
      }
      return parsed;
    }
    ```

    And within the handler, **always unwrap the CALL nested result set** before accessing the row:

    ```typescript
    if (success && Array.isArray(db.queryResults[0]) && db.queryResults[0].length > 0) {
      const resultSet = Array.isArray(db.queryResults[0][0]) ? db.queryResults[0][0] as unknown[] : db.queryResults[0];
      const row = resultSet[0] as Record<string, unknown>;
      const firstVal = Object.values(row)[0];
      const spEnvelope = parseSpEnvelope(firstVal);
      // ...
    }
    ```

    **Rationale:** mysql2 `CALL` returns `rows = [[{response: Buffer}, ...], OkPacket]`. Accessing `db.queryResults[0][0]` without unwrapping yields the inner data array — not a row object — causing `Object.values()` to return the row object itself rather than the Buffer column value, which results in the Buffer being passed through un-decoded and serialized as `{type:"Buffer", data:[...]}` in the response.

- **MANDATORY** WHEN a successful HTTP response includes the returned value from database stored procedure, the response format will be:

    ```
    {
        "success": <boolean>,
        "http_code": <number>,
        "message": <string>,
        "data": 
            {
                "success": <boolean>,
                "message" <string>,
                "json_data": <JSON object>
            }
    }
    ```

- **MANDATORY** IMPLEMENT OpenAPI Swagger
- **MANDATORY** UPDATE OpenAPI Swagger on any endpoints codes changes or new endpoints 
- **IMPORTANT** **MANDATORY** Synchronize codes updates/modifications with OpenAPI documentations, Swagger and its corresponding parameter schemas and example values, response schemas and example values
- **MANDATORY** UPDATE file `project_progress/TASKS_BREAKDOWN_CHECKLIST.md` or user specified task checklist file after completion of a specific task or sub-task
- **MANDATORY** CREATE AND UPDATE file `project_progress/PROJECT_TRACKER.md` or user specified project tracker file, this will contain a detailed brief and concise activities executed of a completed task or sub-task and specify the **Next Task** to be executed 

## OpenAPI documentation and Swagger

- **MANDATORY** each backend API end-point settings/configuration/schemas in Swagger must have its own JSON file save to folder `src/jsondef`
- **MANDATORY** any code modifications in the backend service API end-points must be reflected in the OpenAPI documentation
- **MANDATORY** any code modifications in the backend service API end-points must be synchronize with Swagger by re-buidling its end-points and corresponding parameters schemas, example values, response schemas and example values

## Testing Requirements:
- **MANDATORY** Carryout ESLINT on all related codes
- **MANDATORY** Generate sample data to use in testing API endpoints
- **MANDATORY** Sample data are queried in the actual affected database' tables
- Each completed function must be tested before marking complete
- Integration tests required for all API endpoints
- Performance tests for database operations
- Security tests for authentication and authorization

## **MANDATORY** DO NOT MODIFY:
- `src/lib/dbconn.ts` - **MANDATORY** Use as-is for all database operations
- `src/lib/errorlogger.ts` - **MANDATORY** Use as-is for all error logging

----

# **MANDATORY** DATABASE CREDENTIALS TO USE, ADD TO `.env` FILE

DB_HOST=192.168.4.141
DB_PORT=3306
DB_USER=developer
DB_PASSWORD=dev10180
DB_NAME=mysql

----

# **MANDATORY** EXCLUSIVE SERVICE PORTS TO USE, ADD TO `.env` FILE

BACKEND_PORT = 3000
FRONTEND_PORT = 3002