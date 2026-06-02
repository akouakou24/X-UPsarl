/* X-UPsarl — En-tête et pied de page mutualisés (source unique).
   Injecté automatiquement sur toutes les pages. Remplace l'en-tête local s'il existe,
   pose une navigation cohérente avec « Accueil » en premier, et gère le menu mobile. */
(function () {
  var NAV = [
    { href: "/index.html",     label: "Accueil",          home: true },
    { href: "/concept.html",   label: "Le Concept" },
    { href: "/investir.html",  label: "Investir" },
    { href: "/e-regul.html",   label: "e-Régul" },
    { href: "/gube.html",      label: "Le GUBE" },
    { href: "/gube-plan.html", label: "Plan / Cadastre" },
    { href: "/contacts.html",  label: "Contacts" }
  ];
  var here = "/" + (location.pathname.split("/").pop() || "index.html");

  var links = NAV.map(function (n) {
    var active = (here === n.href) ? " active" : "";
    var ic = n.home ? "⌂ " : "";
    return '<a href="' + n.href + '" class="' + (n.home ? "home" : "") + active + '">' + ic + n.label + "</a>";
  }).join("");

  var header =
    '<header class="xup-header">' +
      '<a href="/index.html" class="xup-logo"><img src="/assets/img/logo-compact.svg" alt="X-UPsarl"></a>' +
      '<button class="xup-burger" id="xupBurger" aria-label="Menu" aria-expanded="false">☰</button>' +
      '<nav class="xup-nav" id="xupNav">' + links + '</nav>' +
      '<div class="xup-header-right">' +
        '<a href="/connexion.html" class="btn-connexion">CONNEXION</a>' +
        '<a href="/inscription.html" class="btn-inscription">INSCRIPTION</a>' +
      '</div>' +
    '</header>';

  var footer =
    '<footer class="xup-footer">' +
      '<div>© 2026 — <strong>XUP Sarl</strong> | Tous droits réservés</div>' +
      '<div><a href="#">Mentions Légales</a> | <a href="#">CGU</a> | <a href="#">FAQ</a></div>' +
      '<div class="social">SUIVEZ NOUS SUR <a href="#">f</a><a href="#">t</a><a href="#">in</a></div>' +
    '</footer>';

  function build() {
    // En-tête : remplace celui de la page s'il existe, sinon l'ajoute en haut
    var oldH = document.querySelector("header.xup-header");
    if (oldH) oldH.outerHTML = header;
    else document.body.insertAdjacentHTML("afterbegin", header);

    // Pied : remplace celui de la page s'il existe, sinon l'ajoute à la fin
    var oldF = document.querySelector("footer.xup-footer");
    if (oldF) oldF.outerHTML = footer;
    else document.body.insertAdjacentHTML("beforeend", footer);

    // Menu mobile (hamburger)
    var burger = document.getElementById("xupBurger");
    var nav = document.getElementById("xupNav");
    if (burger && nav) {
      burger.addEventListener("click", function () {
        var open = nav.classList.toggle("open");
        burger.setAttribute("aria-expanded", open ? "true" : "false");
      });
      nav.querySelectorAll("a").forEach(function (a) {
        a.addEventListener("click", function () { nav.classList.remove("open"); });
      });
    }
  }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", build);
  else build();
})();
