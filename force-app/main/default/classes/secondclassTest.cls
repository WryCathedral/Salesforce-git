@isTest
private class secondclassTest {
    @isTest
    static void testMethodone() {
        secondclass.methodone();
        System.assert(true, 'methodone executed');
    }
}
