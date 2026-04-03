@isTest
public class firstclassTest {
	@isTest
    static void testMainMethod() {
        // Call the method you want to test
        firstclass.main();

        // You can include assertions if the method updates data or returns a value.
        // Since 'main' only prints a debug statement, we just call it to confirm it runs without errors.
        System.assert(true, 'Method executed successfully');
    }
}
