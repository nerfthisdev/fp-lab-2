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
# бенчмарк операций add/mem/remove (по умолчанию 50000 элементов)
dune exec fp-lab-2-bench

# на другом размере
dune exec fp-lab-2-bench -- -n 100000
```
