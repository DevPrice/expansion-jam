float dot2(vec2 x){
    return dot(x, x);
}

float sdCircle(vec2 p, float r){
    return length(p)- r;
}

float sdRoundedBox(in vec2 p, in vec2 b, in vec4 r ){
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0)+ length(max(q,0.0))- r.x;
}

float sdOrientedBox(in vec2 p, in vec2 a, in vec2 b, float th ){
    float l = length(b-a);
    vec2  d = (b-a)/l;
    vec2  q = (p-(a+b)*0.5);
          q = mat2(vec2(d.x,-d.y),vec2(d.y,d.x))*q;
          q = abs(q)-vec2(l,th)*0.5;
    return length(max(q,0.0))+ min(max(q.x,q.y),0.0);    
}

float sdSegment(in vec2 p, in vec2 a, in vec2 b ){
    vec2 pa = p-a, ba = b-a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length(pa - ba*h );
}

float sdTriangle(in vec2 p, in vec2 p0, in vec2 p1, in vec2 p2 ){
    vec2 e0 = p1-p0, e1 = p2-p1, e2 = p0-p2;
    vec2 v0 = p -p0, v1 = p -p1, v2 = p -p2;
    vec2 pq0 = v0 - e0*clamp(dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
    vec2 pq1 = v1 - e1*clamp(dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
    vec2 pq2 = v2 - e2*clamp(dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign(e0.x*e2.y - e0.y*e2.x );
    vec2 d = min(min(vec2(dot(pq0,pq0), s*(v0.x*e0.y-v0.y*e0.x)),
                     vec2(dot(pq1,pq1), s*(v1.x*e1.y-v1.y*e1.x))),
                     vec2(dot(pq2,pq2), s*(v2.x*e2.y-v2.y*e2.x)));
    return -sqrt(d.x)*sign(d.y);
}

float sdPentagon(in vec2 p, in float r ){
    const vec3 k = vec3(0.809016994,0.587785252,0.726542528);
    p.x = abs(p.x);
    p -= 2.0*min(dot(vec2(-k.x,k.y),p),0.0)*vec2(-k.x,k.y);
    p -= 2.0*min(dot(vec2(k.x,k.y),p),0.0)*vec2(k.x,k.y);
    p -= vec2(clamp(p.x,-r*k.z,r*k.z),r);    
    return length(p)*sign(p.y);
}

float sdPentagram(in vec2 p, in float r ){
    const float k1x = 0.809016994; // cos(π/ 5)= ¼(√5+1)
    const float k2x = 0.309016994; // sin(π/10)= ¼(√5-1)
    const float k1y = 0.587785252; // sin(π/ 5)= ¼√(10-2√5)
    const float k2y = 0.951056516; // cos(π/10)= ¼√(10+2√5)
    const float k1z = 0.726542528; // tan(π/ 5)= √(5-2√5)
    const vec2  v1  = vec2(k1x,-k1y);
    const vec2  v2  = vec2(-k1x,-k1y);
    const vec2  v3  = vec2(k2x,-k2y);
    
    p.x = abs(p.x);
    p -= 2.0*max(dot(v1,p),0.0)*v1;
    p -= 2.0*max(dot(v2,p),0.0)*v2;
    p.x = abs(p.x);
    p.y -= r;
    return length(p-v3*clamp(dot(p,v3),0.0,k1z*r))
           * sign(p.y*v3.x-p.x*v3.y);
}

float sdStar(in vec2 p, in float r, in int n, in float m){
    // next 4 lines can be precomputed for a given shape
    float an = 3.141593/float(n);
    float en = 3.141593/m;  // m is between 2 and n
    vec2  acs = vec2(cos(an),sin(an));
    vec2  ecs = vec2(cos(en),sin(en)); // ecs=vec2(0,1)for regular polygon

    float bn = mod(atan(p.x,p.y),2.0*an)- an;
    p = length(p)*vec2(cos(bn),abs(sin(bn)));
    p -= r*acs;
    p += ecs*clamp(-dot(p,ecs), 0.0, r*acs.y/ecs.y);
    return length(p)*sign(p.x);
}

float sdMoon(vec2 p, float d, float ra, float rb ){
    p.y = abs(p.y);
    float a = (ra*ra - rb*rb + d*d)/(2.0*d);
    float b = sqrt(max(ra*ra-a*a,0.0));
    if(d*(p.x*b-p.y*a)> d*d*max(b-p.y,0.0))
          return length(p-vec2(a,b));
    return max((length(p          )-ra),
               -(length(p-vec2(d,0))-rb));
}

float sdHorseshoe(in vec2 p, in vec2 c, in float r, in vec2 w ){
    p.x = abs(p.x);
    float l = length(p);
    p = mat2(vec2(-c.x, c.y), vec2(c.y, c.x))*p;
    p = vec2((p.y>0.0 || p.x>0.0)?p.x:l*sign(-c.x),
             (p.x>0.0)?p.y:l );
    p = vec2(p.x,abs(p.y-r))-w;
    return length(max(p,0.0))+ min(0.0,max(p.x,p.y));
}

float sdHeart(in vec2 p ){
    p.x = abs(p.x);

    if(p.y+p.x>1.0 )
        return sqrt(dot2(p-vec2(0.25,0.75)))- sqrt(2.0)/4.0;
    return sqrt(min(dot2(p-vec2(0.00,1.00)),
                    dot2(p-0.5*max(p.x+p.y,0.0))))* sign(p.x-p.y);
}

float sdCross(in vec2 p, in vec2 b, float r ){
    p = abs(p); p = (p.y>p.x)? p.yx : p.xy;
    vec2  q = p - b;
    float k = max(q.y,q.x);
    vec2  w = (k>0.0)? q : vec2(b.y-p.x,-k);
    return sign(k)*length(max(w,0.0))+ r;
}

float sdRoundedX(in vec2 p, in float w, in float r ){
    p = abs(p);
    return length(p-min(p.x+p.y,w)*0.5)- r;
}
