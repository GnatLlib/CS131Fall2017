import java.util.concurrent.atomic.*;
class BetterSafe2 implements State{
    private AtomicInteger[] value;
    private byte maxval;

    BetterSafe2(byte[] v) { 
        value = new AtomicInteger[v.length];
        int c = 0;
        for(byte b : v){
            value[c] = new AtomicInteger((int)b);
            c++;
        }

        maxval = 127; 
    }

    BetterSafe2(byte[] v, byte m) {
        value = new AtomicInteger[v.length];
        int c = 0;
        for(byte b : v){
            value[c] = new AtomicInteger((int)b);
            c++;
        }
          maxval = m; 
        }

    public int size() { return value.length; }

    public byte[] current() {
         byte[] result = new byte[value.length];
         
         for (int i = 0; i < value.length; i++){
            result[i] = (byte) value[i].get();
           
         }
         return result; 
        }

    public boolean swap(int i, int j) {
    int decrementMe = value[i].get();
    int incrementMe = value[j].get();
	if (decrementMe <= 0 || incrementMe >= maxval) {
	    return false;
	}
    return 
	(value[i].compareAndSet(decrementMe, decrementMe-1) &&
	value[j].compareAndSet(incrementMe, incrementMe+1));
	
    }
}