A Stan reimplementation of the knower-level model
=================================================

[post-url]: https://yongfu.name/knower-levels

Refer to this [blog post][post-url] for a detailed introduction to the background and implementation.

## Data

- Raw data from [Bayesian Cognitive Modeling](https://bayesmodels.com) (Lee & Wagenmakers, 2013): `raw/NumberConcepts/fc_given.mat`
- Exported JSON format: `made/data.json`

## Source Code

- Model source code: `src/m2.stan`
  - `src/m3.stan`: Reference implementation for the original knower-level model. It is a syntactic update of [Martin Smira's Stan translation of the original WinBUGS code in the book](https://github.com/stan-dev/example-models/blob/master/Bayesian_Cognitive_Modeling/CaseStudies/NumberConcepts/NumberConcept_1_Stan.R).
- Validation of model on synthetic data: `src/sim.R`, `src/validate.R`
- Fitting model to the real Give-*N* data: `src/fit2.R`

## Inference Results

The results are NOT identical to those presented in Lee & Wagenmakers (2013). Refer to the [blog post][post-url] for details.

<img src="docs/base-rate.svg" style="background:white">

<img src="docs/knower-levels.svg" style="background:white">

## References

- Lee, M. D., & Sarnecka, B. W. (2010). A Model of Knower-Level Behavior in Number-Concept Development. Cognitive Science, 34(1), 51–67.  
- Lee, M. D., & Sarnecka, B. W. (2011). Number-knower levels in young children: Insights from Bayesian modeling. Cognition, 120(3), 391–402.  
- Lee, M. D., & Wagenmakers, E.-J. (2013). Bayesian cognitive modeling: A practical course. (pp. xiii, 264). Cambridge University Press.
