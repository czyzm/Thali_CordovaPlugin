package io.jxcore.node;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.thaliproject.p2p.btconnectorlib.PeerProperties;

import java.lang.reflect.Field;
import java.net.Socket;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.MatcherAssert.assertThat;

public class SocketThreadBaseTest {
    ListenerMock mListenerMock;
    InputStreamMock mInputStreamMock;
    OutputStreamMock mOutputStreamMock;
    SocketThreadBaseMock mSocketThreadBaseMock;

    @Before
    public void setUp() throws Exception {
        mInputStreamMock = new InputStreamMock();
        mOutputStreamMock = new OutputStreamMock();
        mListenerMock = new ListenerMock();
        mSocketThreadBaseMock = new SocketThreadBaseMock(null, mListenerMock, mInputStreamMock, mOutputStreamMock);
    }

    @After
    public void tearDown() throws Exception {

    }

    @Test
    public void testGetListener() throws Exception{
        assertThat("getListener() returns equal listener to mListenerMock",
                mSocketThreadBaseMock.getListener(), is(equalTo((SocketThreadBase.Listener)mListenerMock)));
    }

    @Test
    public void testGetPeerProperties() throws Exception {
        assertThat("getProperties() should return null", mSocketThreadBaseMock.getPeerProperties(),
                is(nullValue()));

        PeerProperties pp = new PeerProperties("00:11:22:33:44:55");
        Field fPeerProperties = mSocketThreadBaseMock.getClass().getSuperclass().getDeclaredField("mPeerProperties");
        fPeerProperties.setAccessible(true);
        fPeerProperties.set(mSocketThreadBaseMock, pp);

        assertThat("getProperties() should return PeerProperties equal to pp",
                mSocketThreadBaseMock.getPeerProperties(), is(equalTo(pp)));
    }

    @Test
    public void testSetPeerProperties() throws Exception {
        PeerProperties mPeerProperties1 = new PeerProperties("00:11:22:33:44:55");
        PeerProperties mPeerProperties2 = new PeerProperties("11:11:22:33:44:55");

        mSocketThreadBaseMock.setPeerProperties(mPeerProperties1);
        assertThat("getProperties should be equal to mPeerProperties1",
                mSocketThreadBaseMock.getPeerProperties(), is(equalTo(mPeerProperties1)));

        mSocketThreadBaseMock.setPeerProperties(mPeerProperties2);
        assertThat("getProperties should be equal to mPeerProperties2",
                mSocketThreadBaseMock.getPeerProperties(), is(equalTo(mPeerProperties2)));
    }

    @Test
    public void testGetLocalHostAddressAsString() throws Exception {
    }

    @Test
    public void testClose() throws Exception {
        mSocketThreadBaseMock.close();

        assertThat("mReceivingThread is null", mSocketThreadBaseMock.mReceivingThread,
                is(nullValue()));
        assertThat("mSendingThread is null", mSocketThreadBaseMock.mSendingThread,
                is(nullValue()));
        assertThat("mLocalInputStream is null", mSocketThreadBaseMock.mLocalInputStream,
                is(nullValue()));
        assertThat("mLocalOutputStream is null", mSocketThreadBaseMock.mLocalOutputStream,
                is(nullValue()));
        assertThat("mLocalhostSocket is null", mSocketThreadBaseMock.mLocalhostSocket,
                is(nullValue()));
    }

    @Test
    public void testEquals() throws Exception {
        SocketThreadBaseMock mSocketThreadBaseMock1 =
                new SocketThreadBaseMock(null, mListenerMock, mInputStreamMock, mOutputStreamMock);
        SocketThreadBaseMock mSocketThreadBaseMock2 =
                new SocketThreadBaseMock(null, mListenerMock, mInputStreamMock, mOutputStreamMock);
        SocketThreadBaseMock mSocketThreadBaseMock3 =
                new SocketThreadBaseMock(null, mListenerMock, mInputStreamMock, mOutputStreamMock);

        mSocketThreadBaseMock1.setPeerProperties(new PeerProperties("00:11:22:33:44:55"));
        mSocketThreadBaseMock2.setPeerProperties(new PeerProperties("11:11:22:33:44:55"));
        mSocketThreadBaseMock3.setPeerProperties(new PeerProperties("00:11:22:33:44:55"));

        assertThat("mSocketThreadBaseMock1 not equal to mSocketThreadBaseMock2",
                mSocketThreadBaseMock1.equals(mSocketThreadBaseMock2), is(false));
        assertThat("mSocketThreadBaseMock3 not equal to mSocketThreadBaseMock2",
                mSocketThreadBaseMock3.equals(mSocketThreadBaseMock2), is(false));
        assertThat("mSocketThreadBaseMock1 equal to mSocketThreadBaseMock3",
                mSocketThreadBaseMock1.equals(mSocketThreadBaseMock3), is(true));
    }

    @Test
    public void testStartStreamCopyingThreads() throws Exception {
    }

    @Test
    public void testCloseLocalSocketAndStreams() throws Exception {
        mSocketThreadBaseMock.mLocalInputStream = mInputStreamMock;
        mSocketThreadBaseMock.mLocalOutputStream = mOutputStreamMock;
        mSocketThreadBaseMock.mLocalhostSocket = new Socket();

        assertThat("mLocalInputStream is not null", mSocketThreadBaseMock.mLocalInputStream,
                is(notNullValue()));
        assertThat("mLocalOutputStream is not null", mSocketThreadBaseMock.mLocalOutputStream,
                is(notNullValue()));
        assertThat("mLocalhostSocket is not null", mSocketThreadBaseMock.mLocalhostSocket,
                is(notNullValue()));

        mSocketThreadBaseMock.closeLocalSocketAndStreams();

        assertThat("mLocalInputStream is null", mSocketThreadBaseMock.mLocalInputStream,
                is(nullValue()));
        assertThat("mLocalOutputStream is null", mSocketThreadBaseMock.mLocalOutputStream,
                is(nullValue()));
        assertThat("mLocalhostSocket is null", mSocketThreadBaseMock.mLocalhostSocket,
                is(nullValue()));
    }

    @Test
    public void testCloseBluetoothSocketAndStreams() throws Exception {
        assertThat("Input stream is not closed",
                ((InputStreamMock) mSocketThreadBaseMock.mBluetoothInputStream).isClosed, is(false));
        assertThat("Output stream is not closed",
                ((OutputStreamMock) mSocketThreadBaseMock.mBluetoothOutputStream).isClosed, is(false));

        mSocketThreadBaseMock.closeBluetoothSocketAndStreams();

        assertThat("Input stream is closed",
                ((InputStreamMock) mSocketThreadBaseMock.mBluetoothInputStream).isClosed, is(true));
        assertThat("Output stream is closed",
                ((OutputStreamMock) mSocketThreadBaseMock.mBluetoothOutputStream).isClosed, is(true));

    }
}
