function mcorientation(source::Mocapdata,lmarker1::Int,rmarker1::Int,target::Mocapdata,lmarker2::Int,rmarker2::Int)
    halves(x) = (x[:,1:div(size(x,2),2)],  x[:,div(size(x,2),2)+1:end])
    s1,s2 = halves(Matrix(mcgetmarker(source,[lmarker1,rmarker1]).data))
    s3,s4 = halves(Matrix(mcgetmarker(target,[lmarker2,rmarker2]).data))
    d1=s2-s1; # segment (source)
    v1=[-d1[:,2] d1[:,1]]; # gaze direction
    az1=atan.(v1[:,2],v1[:,1]);
    r1=hypot.(v1[:,1],v1[:,2]);
    d2=(s4+s3)/2-(s1+s2)/2;
    v2=[d2[:,1] d2[:,2]]; # direction to target
    az2 = atan.(v2[:,2],v2[:,1])
    r2 = hypot.(v2[:,1],v2[:,2])
    or = 180 .* (az1.-az2)./π
    return or, r2
end
