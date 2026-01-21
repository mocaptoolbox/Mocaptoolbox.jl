    """
    rotates two mocap structures so that they lie at a similar distance from the camera view and merges the result
    """
function mcrotatedyad(m1::Mocapdata, m2::Mocapdata)::Mocapdata
    me = mcmerge(m1,m2)
    ma1,ma2 = Matrix.([m1.data,m2.data])
    mx1,mx2 = nanmean.([ma1[:,1:3:end],ma2[:,1:3:end]]) # mean pos x
    my1,my2 = nanmean.([ma1[:,2:3:end],ma2[:,2:3:end]]) # mean pos y

    #center dyad
    mx=(mx1+mx2)/2;
    my=(my1+my2)/2;
    m=mctranslate(me,[-mx, -my, 0]);

    alpha=-atan((mx2-mx1)/(my2-my1)); # because theta = arctan(opp/adj)
    # original code in matlab is atan((my2-my1)/(mx2-mx1)), but Makie view swaps x and y
    return mcrotate(me,180-180*alpha/pi);
end
