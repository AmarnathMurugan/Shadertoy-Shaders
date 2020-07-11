//Buffer for mandlebrot shader
const int KEY_Z  = 90;
const int KEY_X  = 88;
const int KEY_LEFT  = 37;
const int KEY_UP    = 38;
const int KEY_RIGHT = 39;
const int KEY_DOWN  = 40;
float zoom = 0.05;
vec2 offset = vec2(0);
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
	uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;
    
    vec4 m = iMouse/iResolution.xyxy;
    
    zoom = texelFetch(iChannel0,ivec2(0,0),0).x;
    zoom =max(0.05, mix(zoom,zoom+zoom*0.01,texelFetch(iChannel1,ivec2(KEY_X,0),0).x));
    zoom =max(0.05, mix(zoom,zoom-zoom*0.01,texelFetch(iChannel1,ivec2(KEY_Z,0),0).x));
    offset = texelFetch(iChannel0,ivec2(0,0),0).yz; 
    offset.x+= (texelFetch(iChannel1,ivec2(KEY_RIGHT,0),0).x - texelFetch(iChannel1,ivec2(KEY_LEFT,0),0).x)*0.001/zoom;
    offset.y+= (texelFetch(iChannel1,ivec2(KEY_UP,0),0).x - texelFetch(iChannel1,ivec2(KEY_DOWN,0),0).x)*0.001/zoom;
    fragColor = vec4(zoom,offset.x,offset.y,1.0);
} 
