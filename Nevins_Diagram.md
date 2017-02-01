## DIAGRAMS WITH MARKDOWN##

### Matthias Nevins - Univeristy of Vermont###

### February 1, 2017###



- I use the mermaid chart diagram below to replicate a decision tree created to map out a potential outcome of a hypothesis test. My research will be using a forest simulation model to evaluate forest management decisions over time under climate change.

- The hypothesis being testing is: Forest resistance to climate change, measured by functional diveristy (Fdiv), will decrease over under a *high* climate change emmissions scenerio (Pc) and under *buisness as usual* (Pbau) forest management. 

  - The null hypothesis is that *forest resistance over time is not impacted by Pc or Pbau*.

```mermaid
graph TD; 
	A[Functional diveristy changes over time under Pc and Pbau?]; 
	A--no-->B[Null Hypoth is True];
	A--yes-->C{Did Fdiv increase?};
	C--no-->D[Did Fdiv decrease?];
	C--yes-->E[Hypoth is wrong];
	D--no-->F[Null hypoth is true];
	D--yes-->G[Which predicting variable has more influence on Fdiv?];
	G-->H[Pc has greatest influence];
	G-->I[Pbau has greatest influence];
	G-->J[Inconclusive, develop new hypoth];
```

