### Dokumentace pro vývojáře

**Popis problému a celkový přístup**
Projekt řeší implementaci upravené verze hry piškvorky na hexagonální mřížce s využitím axiálního souřadnicového systému $(Q, R)$. Cílem hráčů je vytvořit nepřerušenou řadu 5 políček v jednom ze tří hlavních směrů sítě: $(+1, 0)$, $(0, +1)$, nebo $(+1, -1)$. Na hrací ploše se nacházejí statické překážky, které ztěžují hru.

Pro rozhodování oponenta - umělé inteligence je využit algoritmus minimax s alfa-beta prořezáváním. Algoritmus prohledává stavový prostor do uživatelem specifikované hloubky `Depth`. Vzhledem k vysokému faktoru větvení u piškvorek obsahuje implementace několik optimalizačních triků:
1. **Omezení generování tahů:** Predikáty generují pouze takové tahy, které se nacházejí v bezprostředním okolí již existujících polí na desce, čímž se výrazně zmenšuje stavový prostor
2. **Seřazení tahů heruristikou:** Koncové listy stavového prostoru jsou seřazeny pomocí heuristiky nejdelší řady, která preferuje delší souvislé řady polí (algoritmus umocňuje délku řad na pátou). Individuální tahy `Moves` jsou zároveň při prohledávání řazeny pro rychlejší nalezení lepších alfa-beta ořezů

**Kód a rozdělení do souborů**
Kód je rozdělený do několika vzájemně kooperujících `.pl` souborů reprezentujících specifické části problému, kde každy exportuje své metody v modulech pojmenovaných stejně jako jejich soubor:
* **`Main.pl` (Start a herní smyčka)**
    * Koordinuje běh aplikace a komunikaci mezi moduly
    * Obsahuje vstupní bod aplikace `start/0` a rekurzivní predikát `game_loop/3`, který zpracovává tahy (od hráče i AI), kontroluje výhru pomocí logiky a přepíná tahy hráčů
    * Funkce `generate_random_coordinates/3` se stará o náhodné umístění zadaného počtu překážek na začátku hry

* **`Board.pl` (Správa hrací plochy)**
    * Definuje desku v datové struktuře `board(Radius, AssocCells)`. Deska je uložena jako asociativní pole, kde klíčem je souřadnice `c(Q, R)` a hodnotou stav políčka (`empty`, `player`, `ai`, `obstacle`)
    * Klíčové funkce: `init_board/3` řeší inicializaci prázdné desky, `get_cell/4` a `set_cell/5` bezpečně mění a čtou stavy na hrací ploše s kontrolou platnosti souřadnic

* **`Logic.pl` (Herní pravidla)**
    * Obsahuje deklarace šesti směrů pohybu pro hexagonální mřížku (`direction/2`)
    * Řídí stavy hry pomocí predikátů `check_win/2` a `check_draw/1`. Funkce `check_win/2` kontroluje pět shodných prvků v definovaných osách ze startovní pozice a hledá výherce
    * Nabízí predikát `get_neighbours/4`, který vrací seznam sousedů pole

* **`Ai.pl` (Umělá inteligence oponenta)**
    * Funkce `get_best_move/5` slouží k inicializaci výpočtu a spouští rekurzivní predikát `minimax/9` implementující alfa-beta prořezávání
    * Funkce `generate_moves/3` filtruje legální tahy na základě vzdálenosti k obsazeným políčkům pro optimalizaci výkonu
    * `evaluate_board/3` (a k ní přidružené pomocné funkce) řeší výpočet skóre stavu desky na základě délky otevřených linií u obou hráčů
    * ...A několik dalších pomocných predikátů

* **`IO.pl` (Textový vstup a výstup)**
    * Nabízí pomocné funkce pro čtení inputu hráče a vypisování stavu desky nebo informačních zpráv
    * Predikát `print_board/1` vykresluje hrací plochu s axiálním nakloněním do konzole iterováním přes pole desky a generováním odpovídajících ASCII znaků (`X`, `O`, `.`, `#`) a číselným označením rádků a sloupců
    * Predikát `read_player_move/3` načítá string uživatelského vstupu, parsuje jej do formátu koordinátů a ověřuje jejich správnost.Zpracovává také příkaz pro ukončení hry