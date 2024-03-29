package hawmps;

import aufgabe1.persistence.PersistenceUtilsA1;
import hawmps.adts.fachliche.Adresse;
import hawmps.adts.fachliche.Name;
import hawmps.komponenten.kundenkomponente.IKundenKomponente;
import hawmps.komponenten.kundenkomponente.access.KundenKomponente;
import hawmps.komponenten.kundenkomponente.data_access.Kunde;
import hawmps.komponenten.kundenkomponente.data_access.KundeDTO;
import junit.framework.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import javax.persistence.EntityManager;
import java.rmi.RemoteException;


/**
 * Created with IntelliJ IDEA.
 * User: Sven
 * Date: 04.11.13
 * Time: 20:55
 */
public class KundenKomponenteTests {
    IKundenKomponente kundenKomponente;
    EntityManager entityManager;


    @BeforeMethod
    public void startUpCode() {
        entityManager = PersistenceUtilsA1.createEntityManager();
        kundenKomponente = KundenKomponente.create(entityManager);
    }

    @Test
    public void createKunde() throws RemoteException {
        entityManager.getTransaction().begin();
        KundeDTO kunde = kundenKomponente.createKunde(Name.create("Sven"), Name.create("Bartel"), Adresse.create("qwe str1","hh","22457"));
        Assert.assertTrue(kundenKomponente.findByNachname(Name.create("Bartel")).size() > 0);
        entityManager.getTransaction().commit();
    }

}
