---

title: TikZ Hakyll Minimal Example
published: 2019-01-09

---

This git repository contains a minimal example for how to easily embed TikZ diagrams into your Hakyll website. I wrote up a [blog post](https://taeer.bar-yam.me/blog/posts/hakyll-tikz) on how it works, but it should be fairly self-explanatory.

The end result is that you can write this in the markdown:

````latex
```tikzpicture
\node (X) {$X$};
\node (Y) [below of=X, left of=X] {$Y$};
\node (Y') [below of=X, right of=X] {$Y^\prime$};
\draw[->] (Y) to node {$i$} (X);
\draw[->] (Y') to node [swap] {$i^\prime$} (X);
\draw[transform canvas={yshift=0.5ex}, ->] (Y) to node {$\alpha$} (Y');
\draw[transform canvas={yshift=-0.5ex}, ->] (Y') to node {$\alpha^{-1}$} (Y);
```
````

and the output in your website will be this:

```tikzpicture
\node (X) {$X$};
\node (Y) [below of=X, left of=X] {$Y$};
\node (Y') [below of=X, right of=X] {$Y^\prime$};
\draw[->] (Y) to node {$i$} (X);
\draw[->] (Y') to node [swap] {$i^\prime$} (X);
\draw[transform canvas={yshift=0.5ex}, ->] (Y) to node {$\alpha$} (Y');
\draw[transform canvas={yshift=-0.5ex}, ->] (Y') to node {$\alpha^{-1}$} (Y);
```
