#define R return
#define P putchar
#define T x->q
typedef struct a{struct a*x,*y;int q;}b,*c;c M(q){
c x=malloc(sizeof(b));x->x=x->y=0;T=q;R x;}c f();c
n(){int c=getchar();if(c==40)R f();if(c==41||c==-1
)R 0;if(!isspace(c)&&isalpha(c))R M(c);R n();}c f(
){c x=M(-1),y,z;z=x->x=n();if(!z)R 0;while(y=n())z
=z->y=y;R x;}void q(c x){if(!x)R;if(~T)P(T);else{c
z=x->x;while(z->y){P(40);z=z->y;}z=x->x;q(z);while
(z=z->y){q(z);P(41);}}}main(){q(f());}
