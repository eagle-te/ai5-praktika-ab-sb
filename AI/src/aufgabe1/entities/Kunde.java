package aufgabe1.entities;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import java.io.Serializable;
import java.util.Set;

/**
 * Date: 04.10.13
 * Time: 16:54
 */
@Entity
public class Kunde implements Serializable{

    @Id
    private int kdnr;

    private String nachname;

    @OneToOne
    private Bankkonto bankkonto;

    @OneToMany
    private Set<Kinokarte> kinokarten;

    public Kunde() {
    }

    private Kunde(int kdnr, String nachname, Bankkonto bankkonto, Set<Kinokarte> kinokarten) {
        this.kdnr = kdnr;
        this.nachname = nachname;
        this.bankkonto = bankkonto;
        this.kinokarten = kinokarten;
    }

    public static Kunde create(int kdnr, String nachname, Bankkonto bankkonto, Set<Kinokarte> kinokarten) {
        return new Kunde(kdnr, nachname, bankkonto, kinokarten);
    }

    public int getKdnr() {
        return kdnr;
    }

    public void setKdnr(int kdnr) {
        this.kdnr = kdnr;
    }

    public String getNachname() {
        return nachname;
    }

    public void setNachname(String nachname) {
        this.nachname = nachname;
    }

    public Bankkonto getBankkonto() {
        return bankkonto;
    }

    public void setBankkonto(Bankkonto bankkonto) {
        this.bankkonto = bankkonto;
    }

    public Set<Kinokarte> getKinokarten() {
        return kinokarten;
    }

    public void setKinokarten(Set<Kinokarte> kinokarten) {
        this.kinokarten = kinokarten;
    }
}
