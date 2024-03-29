shader "CYF/DoomSprite"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue" = "Transparent"}

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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;

            float4x4 MVP;

            float4 pos;

            float scale;

            v2f vert(appdata v)
            {
                v2f o;
                
                float yRotation = MVP[0].y;
                //This makes the sprite follow the camera
                v.vertex = float4(cos(yRotation) * v.vertex.x * scale, v.vertex.y * scale, -sin(yRotation) * v.vertex.x * scale, 1.0);
                
                MVP[0].y = 0;
                o.vertex = mul(MVP, v.vertex + pos);
                MVP[0].y = yRotation;

                o.uv = v.uv;
                
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                
                clip(color.a - 0.001);
                
                return color;
            }
        ENDCG
        }
    }
}
