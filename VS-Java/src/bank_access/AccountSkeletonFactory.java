package bank_access;

import mware_lib.Config;
import mware_lib.ObjectServerMessage;
import mware_lib.Skeleton;
import mware_lib.SkeletonFactory;

import java.net.Socket;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Semaphore;

/**
 * Created with IntelliJ IDEA.
 * User: Sven
 * Date: 28.11.13
 * Time: 22:46
 */
public class AccountSkeletonFactory extends SkeletonFactoryBase implements SkeletonFactory {
    AccountImplBase servant;
    private final static AccountImplBase tester = new AccountImplServant(0.0);
    @Override
    public Skeleton createSkeleton(Socket clientSocket, ObjectServerMessage serviceMessage) {
        Skeleton tmp = new AccountImplSkeleton(this, clientSocket, serviceMessage, getReferences());
        addToSkeletonList(tmp);
        return tmp;
    }

    @Override
    public void setServant(Object servant) {
           this.servant = (AccountImplBase) servant;
    }

    @Override
    public Class getServantClass() {
        return tester.getClass().getSuperclass();
    }


}
