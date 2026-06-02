/* =========================================================================
   X-UPsarl — Données client côté navigateur (extraites du modèle SQLite)
   Reflète la base xup.db (schema.sql + seed.sql)
   ========================================================================= */

window.XUP_DATA = {
  villages: [
    { code:'V001', court:'AO', nom:'Anono',          commune:'Cocody',     chef:'KOUASSI Bernard' },
    { code:'V002', court:'AS', nom:'Akouai-Santai',  commune:'Bingerville',chef:"N'GUESSAN Adou" },
    { code:'V003', court:'AK', nom:'Anonkouakouté',  commune:'Cocody',     chef:'YAO Konan' }
  ],

  // Compteurs séquentiels par village (CDC § 9.3)
  compteurs: { V001: 93, V002: 1, V003: 12 },

  statsVillage: {
    V001: { contrats:1250, preneurs:300, bailleurs:900, locataires:15000, quartiers:6 },
    V002: { contrats: 320, preneurs: 80, bailleurs:220, locataires: 4200, quartiers:4 },
    V003: { contrats: 180, preneurs: 45, bailleurs:140, locataires: 2300, quartiers:3 }
  },

  contrats: [
    {
      identifiant:'V001-GUBE-AO091A', village:'V001', statut:'Terrain nu',
      zone:'Zone A', lot:'Lot 91', ilot:'Ilot 12',
      bailleur:'KOUASSI Bernard', preneur:'KOUAME Jean-Pierre',
      operateur:'BAMBA Karim', date_saisie:'2026-01-15'
    },
    {
      identifiant:'V001-GUBE-AO092A', village:'V001', statut:'Maisons Basses',
      zone:'Zone B', lot:'Lot 14', ilot:'Ilot 03',
      bailleur:'KOUAME Daniel', preneur:'TRAORE Mariam',
      operateur:'BAMBA Karim', date_saisie:'2025-09-10'
    },
    {
      identifiant:'V002-GUBE-AS001A', village:'V002', statut:'Terrain nu',
      zone:'Zone Lac', lot:'Lot 02', ilot:'Ilot 01',
      bailleur:"N'GUESSAN Adou", preneur:'DIABATE Mamadou',
      operateur:'BAMBA Karim', date_saisie:'2026-03-01'
    },
    {
      identifiant:'V003-GUBE-AK012A', village:'V003', statut:'Maisons Basses',
      zone:'Zone Sud', lot:'Lot 12', ilot:'Ilot 02',
      bailleur:'YAO Konan', preneur:'KOUAME Jean-Pierre',
      operateur:'OUATTARA Aminata', date_saisie:'2025-12-20'
    }
  ],

  locataires: [
    { num:1,  village:'V001', nom:'KOFFI Stéphane',     appt:'A1', lot:'Lot 91 / Ilot 12', loyer:75000,  recu:'REC-2026-00001', date:'2026-04-03', operateur:'OUATTARA Aminata' },
    { num:2,  village:'V001', nom:'YAO Christelle',     appt:'A2', lot:'Lot 91 / Ilot 12', loyer:75000,  recu:'REC-2026-00002', date:'2026-04-02', operateur:'OUATTARA Aminata' },
    { num:3,  village:'V001', nom:'SORO Ibrahim',       appt:'B1', lot:'Lot 91 / Ilot 12', loyer:125000, recu:'REC-2026-00003', date:'2026-04-05', operateur:'OUATTARA Aminata' },
    { num:4,  village:'V001', nom:'DIALLO Aïcha',       appt:'B2', lot:'Lot 91 / Ilot 12', loyer:125000, recu:'REC-2026-00004', date:'2026-05-08', operateur:'OUATTARA Aminata' },
    { num:5,  village:'V001', nom:'BAMBA Souleymane',   appt:'C1', lot:'Lot 14 / Ilot 03', loyer:180000, recu:'REC-2026-00005', date:'2026-05-04', operateur:'BAMBA Karim' },
    { num:6,  village:'V001', nom:'COULIBALY Awa',      appt:'M1', lot:'Lot 14 / Ilot 03', loyer:200000, recu:'REC-2026-00006', date:'2026-05-04', operateur:'BAMBA Karim' },
    { num:7,  village:'V002', nom:'KONAN Aristide',     appt:'A1', lot:'Lot 02 / Ilot 01', loyer:90000,  recu:'REC-2026-00012', date:'2026-04-09', operateur:'BAMBA Karim' },
    { num:8,  village:'V003', nom:'TANOH Roselyne',     appt:'A1', lot:'Lot 12 / Ilot 02', loyer:85000,  recu:'REC-2026-00018', date:'2026-04-10', operateur:'OUATTARA Aminata' }
  ],

  projets: [
    { id:1, nom:'BINGERVILLE ANADER', type:'Bail Emphytéotique',
      ville:'Abidjan', commune:'Bingerville', superficie:600,
      montant:150000000, collecte:87500000, part:2500000, duree:150,
      studios:15, chambres:10, exploitation:18, taux:12,
      desc:"Situé en plein coeur de Bingerville, le site en Bail emphytéotique de 600 m² offre toutes les commodités d'un investissement rentable à court terme (4~5 ans soit un bénéfice de 14~13 ans)…" },
    { id:2, nom:'ANONO RESIDENCE', type:'Bail Emphytéotique',
      ville:'Abidjan', commune:'Cocody', superficie:850,
      montant:220000000, collecte:165000000, part:2500000, duree:180,
      studios:12, chambres:8, exploitation:18, taux:13.5,
      desc:"Programme de construction de logements R+2 sur terrain villageois Anono. 12 studios et 8 appartements 2 pièces." },
    { id:3, nom:'ANONKOUAKOUTE LOTS', type:'Bail à Construction',
      ville:'Abidjan', commune:'Cocody', superficie:3000,
      montant:45000000, collecte:45000000, part:1000000, duree:15,
      studios:0, chambres:0, exploitation:2, taux:15,
      desc:"Co-financement court de 5 lots viabilisés à Anonkouakouté pour mise en valeur rapide." },
    { id:4, nom:'COCODY 2 PLATEAUX', type:'Acquisition en Pleine Propriété',
      ville:'Abidjan', commune:'Cocody', superficie:1200,
      montant:650000000, collecte:210000000, part:5000000, duree:90,
      studios:0, chambres:16, exploitation:99, taux:9.5,
      desc:"Acquisition groupée d'un immeuble R+3 aux 2 Plateaux Vallons." }
  ],

  sitesLitigieux: [
    { tf:'TF-99001', acd:'ACD-2018-345', lot:'Bingerville Sud', commune:'Bingerville', litige:'Litige successoral',     statut:'Pendant' },
    { tf:'TF-99022', acd:'ACD-2019-089', lot:'Anono Extension', commune:'Cocody',      litige:'Double cession',         statut:'Pendant' },
    { tf:'TF-99055', acd:'ACD-2020-554', lot:'Yopougon Niangon',commune:'Yopougon',    litige:'Occupation illicite',    statut:'Décision rendue' }
  ]
};

// ====== Génération automatique d'un identifiant de contrat (CDC § 9.3) ======
// Format : V00X-GUBE-XXYYYZ
window.XUP_genererIdentifiantContrat = function(codeVillage, variante='A') {
  const v = window.XUP_DATA.villages.find(v => v.code === codeVillage);
  if (!v) return null;
  // Incrémente le compteur du village
  window.XUP_DATA.compteurs[codeVillage] = (window.XUP_DATA.compteurs[codeVillage] || 0) + 1;
  const yyy = String(window.XUP_DATA.compteurs[codeVillage]).padStart(3,'0');
  return `${v.code}-GUBE-${v.court}${yyy}${variante}`;
};

// ====== Formatage XOF ======
window.XUP_fmtXOF = function(v) {
  if (v == null) return '—';
  return new Intl.NumberFormat('fr-FR').format(v).replace(/ |\s/g,' ') + ' FCFA';
};

// ====== Calcul de date fin de bail ======
window.XUP_calculerFinBail = function(debutISO, dureeMois) {
  if (!debutISO || !dureeMois) return '';
  const d = new Date(debutISO);
  d.setMonth(d.getMonth() + Number(dureeMois));
  return d.toISOString().slice(0,10);
};
