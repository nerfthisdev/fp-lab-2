# FP Lab 2 — Red–Black Set
Тынкевич Валерий Николаевич, P3315, ISU `353054`



## как запускать
```bash
# сборка
dune build

# пример (печатает множество)
dune exec fp-lab-2

# тесты (Alcotest + QCheck)
dune runtest
```

## типы
```ocaml
type color = R | B
type 'a tree = Empty | Node of color * 'a tree * 'a * 'a tree
type 'a t = 'a tree
```
- `Stdlib.compare` задаёт порядок, поэтому элементы должны быть сравнимы полиморфным сравнивателем.

## балансировка
```ocaml
let balance = function
  | B, Node (R, Node (R, a, x, b), y, c), z, d
  | B, Node (R, a, x, Node (R, b, y, c)), z, d
  | B, a, x, Node (R, Node (R, b, y, c), z, d)
  | B, a, x, Node (R, b, y, Node (R, c, z, d)) ->
      Node (R, Node (B, a, x, b), y, Node (B, c, z, d))
  | color, a, x, b -> Node (color, a, x, b)
```
- Рассматриваются 4 «красно‑красных» конфигурации (LL/LR/RL/RR) у чёрного родителя; выполняется поворот и перекраска.
- После рекурсивной вставки корень принудительно красится в чёрный.
- Поиск/вставка — O(log n).

## базовые операции
- `empty`, `is_empty`, `mem`.
- `add x t` — вставка без дубликатов.
- `remove x t` .
- `to_list`/`of_list`, `fold_left`/`fold_right` .

## другие операции
```ocaml
map f t     (* порядок задаёт compare; дубликаты после f исчезают *)
filter p t  (* добавляет только элементы, что удовлетворяют p *)
append a b  (* объединение: fold add b в a *)
intersection a b (* пересечение *)
difference a b   (* разность: a \ b *)
subset a b  (* все элементы a содержатся в b *)
equal a b   (* взаимное subset *)
```

## моноид
- Операция: `append` (объединение множеств).
- Нейтральный элемент: `empty_monoid` = `empty`.
- Свойства ассоциативности и идентичности проверяются QCheck’ом.

## тесты
- Юнит‑тесты Alcotest: `add/mem`, удаление дубликатов, `filter`, `map`, `append`, `remove`.
- Property‑тесты QCheck:
  - `append` ассоциативен, `empty` — левый/правый нейтральный.
  - `mem x (add x s)` всегда истинно.
  - `remove` гарантирует отсутствие элемента.
  - `filter` выдаёт только элементы, удовлетворяющие предикату.

## исполняемый пример
`bin/main.ml` строит множество `{1;2;3}` (дубликаты игнорируются) и печатает его с помощью `pp`.

## бенчмарк
```bash
# отдельный бенчмарк с таблицей
dune exec fp-lab-2-bench

# на другом размере
dune exec fp-lab-2-bench -- -n 1000 -seconds 1 -repeat 3
```

## bench output
```
Throughputs for "add (1000)", "mem (1000)", "remove (1000)" each running 3 times for at least 1 CPU second:
   add (1000):  1.03 WALL ( 1.03 usr +  0.00 sys =  1.03 CPU, minor = 6737.77 MB, major = 0 B) @ 7998.63/s (n=8220)
                1.04 WALL ( 1.04 usr +  0.00 sys =  1.04 CPU, minor = 6737.77 MB, major = 0 B) @ 7886.16/s (n=8220)
                1.02 WALL ( 1.02 usr +  0.00 sys =  1.02 CPU, minor = 6737.77 MB, major = 0 B) @ 8028.94/s (n=8220)
   mem (1000):  1.08 WALL ( 1.08 usr +  0.00 sys =  1.08 CPU, minor = 480.00 kB, major = 0 B) @ 13904.71/s (n=15000)
                1.13 WALL ( 1.13 usr +  0.00 sys =  1.13 CPU, minor = 480.00 kB, major = 0 B) @ 13281.96/s (n=15000)
                1.12 WALL ( 1.12 usr +  0.00 sys =  1.12 CPU, minor = 545.54 kB, major = 0 B) @ 15233.11/s (n=17048)
remove (1000):  1.04 WALL ( 1.04 usr +  0.00 sys =  1.04 CPU, minor = 8575.77 MB, major = 0 B) @ 18.32/s (n=19)
                1.04 WALL ( 1.04 usr +  0.00 sys =  1.04 CPU, minor = 8575.77 MB, major = 0 B) @ 18.26/s (n=19)
                1.03 WALL ( 1.03 usr +  0.00 sys =  1.03 CPU, minor = 8575.77 MB, major = 0 B) @ 18.45/s (n=19)
                 Rate      remove (1000)    add (1000)    mem (1000)
remove (1000)  18.3+-0.1/s            --         -100%         -100%
   add (1000)  7971+- 58/s        43353%            --          -44%
   mem (1000) 14140+-773/s        76980%           77%            --
              minor_allocs/iter major_allocs/iter promoted/iter
   add (1000)         819.68 kB               0 B       7.41 kB
   mem (1000)              32 B               0 B           0 B
remove (1000)         451.36 MB               0 B       4.10 MB
```


Также можно запускать бенчмарки через тесты (`dune runtest`) — там
результаты могут быть скрыты из-за буферизации вывода.
