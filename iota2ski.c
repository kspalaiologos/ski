#define R return
#define P putchar
#define G getchar
#define O t->y
#define Q t->x
typedef struct A{struct A*x,*y;int q;}B;C=1;B*z(q){B*t=malloc(sizeof(B));
Q=O=0;t->q=q;R t;}B*X(B*t){if(Q&&Q->q==1){C=1;B*y=O;O=Q;Q=y;O->q=0;O->x=z
(2);O->y=z(3);}else if(!t->q){Q=X(Q);O=X(O);}R t;}c;B*q(){c=G();if(c==40)
{B*t=z(0);Q=q();O=q();G();R t;}R z(1);}void Y(B*t){if(t->q)P("  SK"[t->q]
);else{P(40);Y(Q);Y(O);P(41);}}main(){B*p=q();while(C){C=0;p=X(p);}Y(p);}
