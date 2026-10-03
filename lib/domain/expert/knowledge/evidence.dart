import '../model/recommendation.dart';

/// Where the knowledge base's thresholds come from. These are references for
/// review, not endorsements: FORJA's rules are organisation heuristics unless
/// the level says otherwise, and they must be reviewed before publishing.
class Sources {
  const Sources._();
  static const forja =
      'Regla de organización de FORJA; heurística pendiente de revisión antes de publicar.';
  static const prog =
      'Reglas prog de FORJA (doble progresión: repeticiones y luego carga), inspiradas en ACSM (2009), Progression models in resistance training for healthy adults.';
  static const acsm2009 =
      'ACSM (2009), Progression models in resistance training for healthy adults.';
  static const helms2016 =
      'Helms y col. (2016), escala de esfuerzo por repeticiones en reserva (RIR).';
  static const schoenfeld2017 =
      'Schoenfeld, Ogborn y Krieger (2017), relación entre series semanales e hipertrofia.';
  static const schoenfeld2016 =
      'Schoenfeld, Ogborn y Krieger (2016), frecuencia de entrenamiento por músculo.';
  static const bell2023 =
      'Bell y col. (2023), consenso Delphi sobre la descarga en deportes de fuerza.';
  static const who2020 =
      'OMS (2020), directrices sobre actividad física: 150–300 min semanales de intensidad moderada.';
  static const compendium =
      'Compendio de Actividades Físicas (tabla met-v1 de FORJA, sin contrastar todavía con la fuente).';
  static const morton2018 =
      'Morton y col. (2018), metaanálisis sobre proteína y entrenamiento de fuerza; ISSN (2017).';
  static const nhlbi =
      'NHLBI/NIH, guías sobre dietas de muy pocas calorías (menos de 800 kcal: solo con supervisión médica).';
  static const lally2010 =
      'Lally y col. (2010), formación de hábitos: la constancia pesa más que la perfección.';
}

/// Shorthands for rule definitions.
const heuristic = Evidence(EvidenceLevel.heuristic, Sources.forja);
