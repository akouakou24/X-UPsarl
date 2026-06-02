/* X-UPsarl — utilitaires UI partagés */

document.addEventListener('DOMContentLoaded', () => {
  // Rendu compteur stats si présent
  const statBox = document.querySelector('[data-stats-village]');
  if (statBox && window.XUP_DATA) {
    const code = statBox.getAttribute('data-stats-village');
    const s = window.XUP_DATA.statsVillage[code];
    if (s) {
      statBox.querySelector('.s-contrats')?.replaceChildren(document.createTextNode(s.contrats));
      statBox.querySelector('.s-preneurs')?.replaceChildren(document.createTextNode(s.preneurs));
      statBox.querySelector('.s-bailleurs')?.replaceChildren(document.createTextNode(s.bailleurs));
      statBox.querySelector('.s-locataires')?.replaceChildren(document.createTextNode(s.locataires));
      statBox.querySelector('.s-quartiers')?.replaceChildren(document.createTextNode(String(s.quartiers).padStart(2,'0')));
    }
  }

  // Sélection village : si présent dans l'URL, on l'applique
  const params = new URLSearchParams(window.location.search);
  const v = params.get('v');
  const selVillage = document.querySelector('select[name="village"]');
  if (v && selVillage) selVillage.value = v;
  selVillage?.addEventListener('change', e => {
    const url = new URL(window.location.href);
    url.searchParams.set('v', e.target.value);
    window.location.href = url.toString();
  });

  // Génération automatique d'identifiant pour la saisie contrat
  const genBtn = document.getElementById('btn-gen-ident');
  if (genBtn) {
    genBtn.addEventListener('click', e => {
      e.preventDefault();
      const village = document.querySelector('select[name="village"]')?.value || 'V001';
      const id = window.XUP_genererIdentifiantContrat(village, 'A');
      document.getElementById('ident-display').textContent = id;
    });
  }

  // Calcul automatique TOTAL MAISONS dans formulaire contrat
  document.querySelectorAll('input[data-compo]').forEach(inp => {
    inp.addEventListener('input', () => {
      let total = 0;
      document.querySelectorAll('input[data-compo]').forEach(i => total += parseInt(i.value || 0));
      const t = document.querySelector('#total-maisons');
      if (t) t.value = total;
    });
  });

  // Calcul automatique fin de bail
  const dureeExp = document.querySelector('#duree-exploit-mois');
  const dateDebut = document.querySelector('#date-debut-bail');
  const finBail = document.querySelector('#fin-bail');
  const recalc = () => {
    if (dateDebut?.value && dureeExp?.value && finBail) {
      finBail.value = window.XUP_calculerFinBail(dateDebut.value, dureeExp.value);
    }
  };
  dureeExp?.addEventListener('input', recalc);
  dateDebut?.addEventListener('change', recalc);
});
