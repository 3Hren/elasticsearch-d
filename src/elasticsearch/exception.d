module elasticsearch.exception;

class PoolIsEmptyError : Error {
    public this() {
        super("pool is empty");
    }   
}