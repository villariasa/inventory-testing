// Stored-Procedure Envelope Parser
// Version: 1.0
// Parses the standard SP response envelope { success, message, json_data }
// returned from procedures in `udf_and_views_inventory`.

export interface SpEnvelope {
    success: boolean;
    message: string;
    json_data: unknown;
}

/**
 * Parse the first value of a stored-procedure result set into the standard
 * service envelope. Handles raw strings, Buffers, and serialized Buffer objects.
 *
 * @param firstVal - the first column value from the SP result set
 * @returns the parsed envelope, or null when the input is null/undefined
 */
export function parseSpEnvelope(firstVal: unknown): SpEnvelope | null {
    let returnValue: SpEnvelope | null = null;

    if (firstVal !== null && firstVal !== undefined) {
        let raw: unknown = firstVal;

        if (Buffer.isBuffer(firstVal)) {
            raw = (firstVal as Buffer).toString('utf8');
        } else if (
            typeof firstVal === 'object' &&
            firstVal !== null &&
            (firstVal as Record<string, unknown>).type === 'Buffer' &&
            Array.isArray((firstVal as Record<string, unknown>).data)
        ) {
            raw = Buffer.from((firstVal as { type: string; data: number[] }).data).toString('utf8');
        }

        const parsed = (typeof raw === 'string' ? JSON.parse(raw) : raw) as SpEnvelope;

        if (typeof parsed.json_data === 'string') {
            try {
                parsed.json_data = JSON.parse(parsed.json_data);
            } catch {
                // leave as-is when json_data is a plain string
            }
        }

        returnValue = parsed;
    }

    return returnValue;
}
