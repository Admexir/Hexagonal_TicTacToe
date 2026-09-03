# Návrh semestrálního projektu: Hexagonální Piškvorky s překážkami

* **Jméno:** Adam Žák
* **UKČO:** 33376753
* **Zvolený jazyk:** Prolog

### Popis problému
Cílem projektu je implementovat upravenou verzi hry **piškvorky**, kde proti sobě hraje lidský hráč a umělá inteligence. 

Hra bude modifikována tak, že se bude odehrávat na **hexagonální mřížce**, která mění geometrii hry (lze tvořit řady ve třech osách namísto standardních čtyř). Dále bude hra ztížena přidáním statických překážek na náhodně či pevně zvolených pozicích, na které nelze umístit kámen. Cílem hráče i AI je umístit 5 svých kamenů do nepřerušené řady.  
*(note: pokud bude implementace projektu příliš komplexní, odstranil bych statické překážky)*

### Formální popis
* **Herní deska:** Bude reprezentována pomocí axiálního souřadnicového systému $(q, r)$ pro šestiúhelníkové mřížky. Deska bude mít fixní poloměr $R$ (např. deska o poloměru 5 tvoří šestiúhelník obsahující 61 polí).
* **Stav buňky:** Každá souřadnice $(q, r)$ může nabývat jednoho ze čtyř stavů: `empty` (prázdno), `player` (kámen hráče), `ai` (kámen počítače), `obstacle` (překážka).
* **Stavový prostor:** Definován aktuálním rozložením kamenů na desce a informací, který hráč je na tahu.
* **Přechody mezi stavy:** Legální tah spočívá ve změně stavu buňky $(q, r)$ ze stavu `empty` na stav aktuálního hráče.
* **Cílový stav:** Existuje posloupnost 5 buněk patřících jednomu hráči takových, že jejich souřadnice na sebe navazují v jednom ze 3 vektorových směrů hexové mřížky: $(+1, 0)$, $(0, +1)$, nebo $(+1, -1)$.
* **Remíza:** Žádná buňka není `empty` a není splněn cílový stav.

### Návrh algoritmu
*(note: je možné, že se návrh algoritmu změní, pokud najdu lepší způsob jak problém řešit)*  
Rozhodovací proces umělé inteligence bude postaven na prohledávání stavového prostoru. 
1. **Minimax:** Hlavní způsob hledání tahů je Minimax algoritmus. Vzhledem k obrovskému faktoru větvení u piškvorek bude pravděpodobně nezbytné implementovat alfa-beta prořezávání. Algoritmus bude prohledávat herní strom do předem definované hloubky $D$.
2. **Heuristická ohodnocovací funkce:** Protože nelze prohledat strom do konce, hra bude ohodnocovat listy prohledávaného stromu.
3. **Generování tahů:** Pro optimalizaci bude Prolog generovat pouze "smysluplné" tahy - tedy pouze umístění kamenů do bezprostředního sousedství již existujících kamenů (hráče i AI), aby se zamezilo zbytečnému prohledávání okrajů prázdné desky.

### Input/Output
* **Vstupy:** 
  * Při spuštění: Nastavení hloubky prohledávání AI a případně velikosti hrací plochy.
  * Během hry: Tah hráče zadávaný přes textovou konzoli jako dvojice souřadnic, např. `Q R`.
* **Výstupy:**
  * Po každém tahu se do konzole překreslí aktuální stav herní desky.
  * Informační výpisy: Upozornění na neplatný tah (např. tah na překážku, mimo desku), zpráva o vítězství/prohře/remíze, apod..

### Popis rozhraní
Projekt bude využívat interaktivní **textové uživatelské rozhraní** v prostředí Prologu. 
* Herní deska bude vykreslována pomocí ASCII znaků formátovaných tak, aby opticky připomínala šestiúhelníkovou síť.
* Hra bude probíhat ve smyčce , která střídá dotaz na vstup od uživatele, výpočet tahu AI, aktualizaci stavu a následné vykreslení desky na standardní výstup.