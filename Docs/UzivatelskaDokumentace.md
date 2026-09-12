# Uživatelská dokumentace

### Ovládání
Program se ovládá prostřednictvím **textové konzole** a k jeho spuštění je nutné načíst hlavní soubor a zavolat příkaz **`start.`**.  
Po spuštění vás program vyzve k počátečnímu nastavení parametrů hry:
* **Hloubka prohledávání AI (AI search depth):** Zadejte celé kladné číslo, které určuje, na kolik tahů dopředu bude umělá inteligence plánovat (např. 5, 6)
* **Velikost herní desky (Board size radius):** Zadejte poloměr hexagonální sítě (velikost herního prostoru)
* **Počet překážek (Board obstacle count):** Zadejte celé kladné číslo, které určuje počet zablokovaných políček, která se vygenerují na náhodných pozicích a nelze na nich hrát
  
Jakmile hra začne, střídáte se s umělou inteligencí. Když jste na tahu, zadáváte své tahy jako dvě souřadnice v axiálním systému (osy Q - vertikální a R - horizontální), které oddělíte mezerou, např. `-5 3`  
Pokud chcete probíhající hru předčasně ukončit, zadejte místo souřadnic slovo `exit`.  

---

### Ukázka rozhraní a symbolika desky
Herní deska je po každém tahu vypsána do konzole v podobě ASCII textu s odsazenými řádky tak, aby vizuálně odpovídala hexagonální mřížce. Využívá se následující symbolika:
* `.` (tečka) – prázdné hrací políčko, na které lze táhnout
* `X` – políčko hráče
* `O` – políčko AI protivníka
* `#` – statická překážka

### Příklady použití
* Standardní zadání tahu: `0 1` nebo `-1 2`
* Ukončení hry: `exit`
* Pokud se pokusíte zahrát mimo hrací desku, na obsazené políčko nebo na překážku, program vás upozorní hláškou `Invalid move...` a vyzve vás k opakování tahu

---
*příklady rozehraných her:*  
*př. 1:*  
```
----- Hexagonal Tic Tac Toe -----
Enter AI search depth: 5
Enter board size radius: 5
Enter board obstacle count: 10
Type moves in the format: Q R or type exit to quit
R\Q   \0\1\2\3\4\5\
-5      . # # # . . 
-4     . # . . # . . 
-3    . # . . . . . . 
-2   . . . . # . . . . 
-1  . . . # . . . . . . 
 0 . . . . # . . . . . . 
 1  . . . . . . . . . . 
 2   . . . . . . . . . 
 3    . . . . . . . . 
 4     . . . . # . . 
 5      . . . . . . 
R\Q    \-5-4-3-2-1\0\
```
  
*př. 2:*  
```
Enter move (Q R): -2 2
R\Q      \0\1\2\3\4\5\6\7\8\
-8         . . . . . . . . . 
-7        . . . . . # . . . . 
-6       . . . X # . . . . . . 
-5      . . . O O X . . . . . # 
-4     . . . X . O . . . . . . . 
-3    # . . X O O O . # . . . . . 
-2   . . . . . O X O # . . . . . . 
-1  . . # . . O O X X . . . . . # . 
 0 . . . . . X . O X . . . . # . . . 
 1  . . . . . . . X O . . . . . . . 
 2   . . . . . . X X X . . . . . . 
 3    . . . . . . . . . . . . . . 
 4     . . # . . . . . . . . . . 
 5      . . . . . . . . . . . . 
 6       . . . . . . . . . . . 
 7        . . . . . . . . . . 
 8         . . . . . . . . . 
R\Q       \-8-7-6-5-4-3-2-1\0\
AI is thinking...
AI's move: -3, 3
```