import java.util.concurrent.atomic.*;
class GetNSet implements State{
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSet(byte[] v) { 
        value = new AtomicIntegerArray(v.length); 
        int c = 0;
        for(byte b : v){
            value.set(c, (int)b);
            c++;
        }

        maxval = 127; 
    }

    GetNSet(byte[] v, byte m) {
        value = new AtomicIntegerArray(v.length);
        int c = 0;
        for(byte b : v){
            value.set(c, (int)b);
            c++;
        }
          maxval = m; 
        }

    public int size() { return value.length(); }

    public byte[] current() {
         byte[] result = new byte[value.length()];
         
         for (int i = 0; i < value.length(); i++){
            result[i] = (byte) value.get(i);
           
         }
         return result; 
        }

    public boolean swap(int i, int j) {
    int decrementMe = value.get(i);
    int incrementMe = value.get(j);
	if (decrementMe <= 0 || incrementMe >= maxval) {
	    return false;
	}
	value.set(i, decrementMe - 1);
	value.set(j, incrementMe + 1);
	return true;
    }
}