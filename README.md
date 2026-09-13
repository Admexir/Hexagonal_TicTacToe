# Hexagonální piškvorky v Prologu (Hexagonal TicTacToe)
Tento projekt je variací hry piškvorky pro **hexagonální herní mřížku**, kde hrajete proti umělé inteligenci, jež se rozhoduje pomocí algoritmu minimax s alfa-beta prořezáváním. Herní plocha také může obsahovat náhodně generované statické překážky.

## Quick start
K běhu programu je zapotřebí mít nainstalovaný [SWI-Prolog](https://www.swi-prolog.org/).
1. Otevřete terminál (nebo příkazovou řádku) ve složce s projektem
2. Spusťte interpret prologu příkazem:
   ```bash
   swipl
   ```
3. Načtěte hlavní soubor programu (`Main.pl`):
   ```prolog
   consult('Main.pl').
   ```
   *(Alternativně můžete použít zkrácený zápis `['Main.pl'].`)*
4. Spusťte hru zavoláním příkazu:
   ```prolog
   start.
   ```
5. Postupujte podle instrukcí na obrazovce (zadejte hloubku hledání AI, velikost desky a počet překážek), své tahy zadávejte jako dvě souřadnice oddělené mezerou (např. `0 1`) a pro ukončení hry napište `exit`

## Dokumentace
Pro detailnější informace o ovládání, pravidlech nebo vnitřní struktuře kódu navštivte následující dokumentaci (naleznete ji v přiložených textových souborech nebo složce s dokumentací):
* **[Uživatelská dokumentace](./Docs/UzivatelskaDokumentace.md)** – Obsahuje detailní návod, jak program používat, ukázky tahů a vysvětlení symboliky herní desky vykreslované v konzoli
* **[Vývojářská dokumentace](./Docs/DeveloperDokumentace.md)** – Popisuje architekturu kódu, detailnější popis AI minimax algoritmu, aplikované optimalizace, využité heuristiky a rozdělení logiky do jednotlivých `.pl` modulů