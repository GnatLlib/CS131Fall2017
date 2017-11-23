import java.util.concurrent.locks.*;
class BetterSafe implements State {

    private byte[] value;
    private byte maxval;
    private ReentrantLock valueLock;
  
    

    BetterSafe(byte[] v) { 
         value = v;
         maxval = 127;  
         valueLock = new ReentrantLock();
         
        }

    BetterSafe(byte[] v, byte m) { 
         value = v;
         maxval = m;
         valueLock = new ReentrantLock();
        }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap( int i, int j){
        valueLock.lock();
        if (value[i] <= 0 || value[j] >= maxval) {
             valueLock.unlock();
	            return false;
        }
        value[i]--;
        value[j]++;
        
        valueLock.unlock();
        return true;
        
    }

}