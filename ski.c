#define R return
#define J putchar
#define g getchar
#define C case
#define G a->a
#define T u->
z=1;typedef struct x{struct x*a,*b;int q;}Y;Y*A(q){Y*u=malloc(sizeof(Y));T a=T b=0;T q=q;R u;}
Y*h(Y*O){if(O->a&&O->a->q==2){z=1;R O->b;}if(O->a&&O->G&&O->G->q==1){z=1;R O->a->b;}if(O->a&&O
->G&&O->G->a&&!O->G->a->q){Y*u=A(3);T a=A(3);T b=A(3);T G=O->G->b;T a->b=O->b;T b->a=O->a->b;T
b->b=O->b;z=1;R u;}if(O->q==3){O->a=h(O->a);O->b=h(O->b);}R O;}Y*r(){switch(g()){C'(':{Y*u=A(3
);T a=r();T b=r();g();R u;}C'I':R A(2);C'S':R A(0);C'K':R A(1);}}void q(Y*t){if(t->q==3){J(40)
;q(t->a);q(t->b);J(41);}J(t->q["SKI "]);}main(){Y*O=r();while(z){z=0;O=h(O);}q(O);} /// KPS :)
