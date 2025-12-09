type color = R | B
type 'a tree = Empty | Node of color * 'a tree * 'a * 'a tree
