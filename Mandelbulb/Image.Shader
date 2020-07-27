//https://www.iquilezles.org/www/articles/mandelbulb/mandelbulb.htm
//http://blog.hvidtfeldts.net/index.php/2011/06/distance-estimated-3d-fractals-part-i/
#define MAX_STEPS 25
#define THRESHOLD 0.1
#define MAX_DIST 10.0
#define MAX_ITR 15
#define ESCAPE_THRESHOLD 2.0
#define PI 3.1415926538
const float Width = 2.0;
const float  FocalLength = 1.0;
const float power = 8.0;
vec3 Origin = vec3(0.0,0.0,-2.5);
float SphereSdf(vec3 p, vec4 sph)
{
	float d = length(sph.xyz - p)-sph.w;
    return d;
}

vec3 GetCartesianCoords(float len, float theta,float phi)
{
	return (len * vec3(sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta)));    
}

vec2 MandelbulbSdf(const in vec3 p)
{
    vec3 z = p;
    float len = 0.0;
    float derivative_len = 1.0;
    float theta,phi;
    int i;
    for(i=0;i<MAX_ITR;i++)
    {
    	len = length(z);
        if(len > ESCAPE_THRESHOLD) break;
        theta = acos(z.z/len)+(iTime/10.0);
        phi = atan(z.x/z.y);
        derivative_len =  power * pow(len,power-1.0) * derivative_len + 1.0;
        len = pow(len,power);
        z = GetCartesianCoords(len,power*theta,power*phi) + p;        
    }
    return vec2(0.5 * log(len) * (len/derivative_len),i);
}

vec3 Raymarch(const in vec3 dir)
{
    float d=0.0;
    vec3 p;
    vec3 finalParams;
    int i;
	for(int i=0;i<MAX_STEPS;i++)
    {
        p = Origin + d * dir;
        finalParams.xy = MandelbulbSdf(p);
        d += finalParams.x;
        if(d<=THRESHOLD || d>=MAX_DIST)
            break;
    }
    finalParams.z = float(i);
    return finalParams;
}

vec3 GetSkyColor(const in vec3 RayDirection)
{	
    float t = 0.5 * (RayDirection.y + 1.0);
    vec3 col = vec3(0.1)*(1.0 - t) + vec3(0.0) * t;
    return col;
}

//source : https://www.shadertoy.com/view/ll2GD3
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 GetColorAtPoint(const in vec3 RayDirection)
{
    vec3 hitInfo = Raymarch(RayDirection);
    float outline = hitInfo.x*20.0;
    float col = (hitInfo.y/float(MAX_ITR));
	if(hitInfo.x*180.0 < MAX_DIST)
    return pal( col, vec3(0.7,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20) )+outline*vec3(1.0,2.0,3.5);
    
    return GetSkyColor(RayDirection);
   
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = (fragCoord/iResolution.xy)-0.5;
    uv.x *= iResolution.x/iResolution.y;  
    vec4 PrevState = texelFetch(iChannel0,ivec2(0,0),0); 
    Origin = GetCartesianCoords(PrevState.x,PrevState.y * PI,0.0);
    vec3 forward = normalize(vec3(0)-Origin);    
    vec3 globalUp = vec3(0.0,1.0,0.0);
    vec3 right = normalize(cross(globalUp,forward));
    vec3 up = cross(forward,right);
    vec3 center = Origin+forward*FocalLength;
    vec3 RayDirection = center+uv.x*right+uv.y*up-Origin;    
	RayDirection = normalize(RayDirection);
	vec3 col = GetColorAtPoint(RayDirection);

    fragColor = vec4(col,1.0);
}
