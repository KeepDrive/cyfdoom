shader "CYF/DoomBG"
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
        ZWrite Off
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
            float xoff;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                i.uv.x=cos(i.uv.x*2.46+0.34)*0.5-0.5-xoff;//Makes the image curve slightly at the edges, the range is [0.34,2.8] instead of [0,pi] so the effect isn't too heavy
                fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - 0.001);
                color.rgb *= color.a;
                return color;
            }
        ENDCG
        }
    }
}
