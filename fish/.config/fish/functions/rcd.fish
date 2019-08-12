function rcd
    set tempfile '/tmp/chosendir'
    /usr/bin/ranger --choosedir=$tempfile $argv

    if test -f $tempfile
        if [ (cat $tempfile) != (pwd) ]
            cd (cat $tempfile)
        end
    end

    rm -f $tempfile
end
