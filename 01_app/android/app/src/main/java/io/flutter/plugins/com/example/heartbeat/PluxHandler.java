public class PluxHandler {


    public PluxHandler(){

        // Initialise the Plux API
        BiopluxCommunication bioplux = new BiopluxCommunicationFactory
                ().getCommunication(Communication.BTH, getBaseContext(), new OnBiopluxDataAvailable(){
            @Override
            public void onBiopluxDataAvailable(BiopluxFrame biopluxFrame) {
                Log.d(TAG, "BiopluxFrame: " + biopluxFrame.toString());
            }
        });


    }
}