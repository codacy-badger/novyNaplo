# Novy Napló
[![time tracker](https://wakatime.com/badge/github/NovySoft/novyNaplo.svg)](https://wakatime.com/badge/github/NovySoft/novyNaplo)

Novy Csodálatos pre-alpha verzióban lévő teljesen nem eredeti kréta kliense.

**Jelenlegi funkciók:**
* Jegyek megtekintése
* Átlagok megtekintése
* Feljegyzések megtekintése

**HAMAROSAN:**
* ~~Feljegyzések~~
* Órarend
* Házifeladat
* Hiányzások
* Grafikonok
* Értesítések
* Jegy számoló - **[HUNCUT2016](https://github.com/huncut2016)** közreműködésével
* Támogatók oldal - **Gáti Úr** közreműködésével
* Szuper egyedi és egyéni beállítások
* **Wear OS** kompatibilitás (felthetőleg teljesen másik applikáció keretében)

# Modulok
* **Flutter:** Evvel a frameworkkel készült az applikáció
* **cupertino_icons**: Az ios ikonokért felel
* **permission_handler**: A későbbiekben a jogokért fog felelni
* **http**: Hálózati kérésekért felel
* **flutter_launcher_icons**: Az applikáció ikonjáért felel
* **shared_preferences**: Az adatok tárolásáért felelős
* **english_words**: Véleltlen angol szavakat generál
* **cipher2**: Az adatok titkosításáért felel
* **connectivity**: Az internet elérhetőségét figyeli
* **package_info**: Ennek a segítségével nézi meg az applikáció saját verzióját
* **flutter_spinkit**: A kis homokóráért felelős
* **diacritic**: A magyar betűk angol megfelelőit tárolja
* **dynamic_theme**: A sötét és fehér téma közt vált
* **firebase_crashlytics**: Applikáció összeomlás esetén jelenti a fontos összeonlási adatokat
* **firebase_analytics**: Az applikáció használatáról jelent fontos adatokat (ki melyik gombot nyomja meg, milyen gyors az api válasz és egyebek)


# Betűtípus
* **Nunito**

# Ismert hibák:
* **Valami was called on null** feltehetőleg parseolási hiba
* **A betöltő homokóra beragad/rootAncestor hibák** feltehetőleg a bejelentkezés gomb véletlen megnyomása és az automata bejelentkezés konfliktusa miatt van ez a hiba
* **_initialButtons == kPrimaryButton is not true** feltehtőleg a bejelentkezés gomb és az automata bejelentkezés konfliktusa miatt van ez a hiba
* **Multiple widgets used the same GlobalKey** a loginPage és a MarksTab ugyanazt a GlobalKeyt használja
* **A ticker was started twice.** jelenleg flutter framework hibának néz ki
* **setCurrentScreen cannot be called with the same class and name** a feljegyzések menüpont hibája, egyértelműen az én kódomban van a hiba, csak még nem tudom, hogy hol


* **Lassú betöltés/leragadás a homokóránál** vagy az előzőekben említett hiba miatt vagy a lassú krétás válasz miatt történik
* **Hibás tanár/tantárgy név** az eredeti krétában van elírva a tanár/tantárgy neve, ez nem az applikáció hibája
