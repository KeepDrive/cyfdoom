shader "CYF/DoomSprite"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        Cull Back
        Lighting Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4x4 MVP;
            float yc,ys,scale;
            float4 pos;

            v2f vert(appdata v)
            {
                v2f o;
                v.vertex=float4(yc*v.vertex.x*scale,v.vertex.y*scale,-ys*v.vertex.x*scale,1.0);
                o.vertex = mul(MVP,v.vertex+pos);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - 0.001);
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}
