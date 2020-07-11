//Mandlebrot Set
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   
    vec2 uv = fragCoord/iResolution.xy;
	uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;
    float col = 0.0;
    vec2 z = vec2(0);
    vec4 PrevState = texelFetch(iChannel0,ivec2(0,0),0);  
    vec2 c = (uv+vec2(PrevState.y*PrevState.x*10.0-0.250,PrevState.z*PrevState.x*10.0))/(PrevState.x*10.0);
    float MaxIter = mix(100.0,5000.0,PrevState.x*0.0007);
    float iter = 0.0;
    for(int i=0;i<int(MaxIter);i++)
    {
    	z = vec2(z.x*z.x-z.y*z.y, 2.0*z.x*z.y)+ c;
        if(length(z)>5.0)
            break;
        iter++;
    }
    col = iter/MaxIter; 
    vec3 fColor = vec3(col,col*=1.6,col*=2.0)*(2.0-col);
    fragColor = vec4(fColor,1.0);
    
} 
