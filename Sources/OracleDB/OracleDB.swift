import Cocilib

public class OracleDB {

    private var con: OpaquePointer?
    private var stmt: OpaquePointer?

    public init() {
        guard OCI_Initialize(nil, nil, UInt32(OCI_ENV_DEFAULT)) == 1 else {
            print("Initialize error")
            return
        }
    }

    deinit {
        OCI_Cleanup()
    }

    @discardableResult public func connect(db: String, user: String, pwd: String) -> Bool {
         self.con = OCI_ConnectionCreate(db, user, pwd, UInt32(OCI_SESSION_DEFAULT))
         return (self.con != nil)
    }

    @discardableResult public func query(sql: String) -> Bool {
        self.stmt = OCI_StatementCreate(self.con)
        var vSql = sql
        if (vSql[vSql.index(before: vSql.endIndex)] == ";") {
            print("warning: please remove ';' from the end of the sql statement")
            vSql.remove(at: vSql.index(before: vSql.endIndex))
        }
        return (OCI_ExecuteStmt(self.stmt, vSql) == 1)
    }

    public func affectedRows() -> UInt32 {
        return OCI_GetAffectedRows(stmt)
    }

    @discardableResult public func commit() -> Bool {
        return (OCI_Commit(con) == 1)
    }

    @discardableResult public func rollback() -> Bool {
        return (OCI_Rollback(con) == 1)
    }

    @discardableResult public func autoCommit (_ enable: Bool) -> Bool {
        return (OCI_SetAutoCommit(con, (enable ? 1 : 0)) == 1)
    }

    public func close() {
        OCI_Cleanup()
    }

    public func storeResults() -> Results? {
        guard let rs = OCI_GetResultset(self.stmt) else {
            print("GetResultset error")
            return nil
        }
        return Results(self.stmt!, rs)
    }
}

public struct Results: Sequence, IteratorProtocol {

    private var stmt: OpaquePointer
    private var rs: OpaquePointer

    public var rowCount: UInt32
    public var columnCount: UInt32

    internal init(_ stmt: OpaquePointer, _ rs: OpaquePointer) {
        self.stmt = stmt
        self.rs = rs
        self.rowCount = OCI_GetRowCount(rs)
        self.columnCount = OCI_GetColumnCount(rs)
    }

    public func next() -> [String: String]? {
        if (OCI_FetchNext(self.rs) == 0) { return nil } 
        var row = [String: String]()
        for index in 1...self.columnCount {
            row[ String(validatingUTF8: OCI_ColumnGetName(OCI_GetColumn(self.rs, index)))! ] = String(validatingUTF8: OCI_GetString(self.rs, index))!
        }  
        return row
    }

    public func numRows() -> UInt32 {
        return self.rowCount
    }

    public func numFields() -> UInt32 {
        return self.columnCount
    }

    public func free() {
        OCI_StatementFree(self.stmt)
    }
}