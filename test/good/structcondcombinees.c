char test(int f[]) {
    int i;
    while(i != (f/2) || i != (f%2)) {
        if(f == 0) {
            return 0;
        } else if(f == 1) {
            return 1;
        } else {
            return f * 2;
        }
    }
    
}
