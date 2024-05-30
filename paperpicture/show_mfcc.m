function melFilterBankVisualization()
    % Number of filters
    numFilters = 20; 
    lowFreq = 0;
    highFreq = 16000;
    fs = 16000;
    lowMel = freq2mel(lowFreq);
    highMel = freq2mel(highFreq);

    melPoints = linspace(lowMel, highMel, numFilters+2);

    hzPoints = mel2freq(melPoints);

    bin = floor((hzPoints/fs) * (fs/2) + 1);


    fBank = zeros(numFilters, floor(fs/2) + 1);
    for m = 1:numFilters
        f1 = bin(m);
        f2 = bin(m+1);
        f3 = bin(m+2);
        for k = f1:f2
            fBank(m, k) = (k - bin(m)) / (bin(m+1) - bin(m));
        end
        for k = f2:f3
            fBank(m, k) = (bin(m+2)-k) / (bin(m+2)-bin(m+1));
        end
    end

    hold on;
    for j = 1:numFilters
        plot(fBank(j, :));
    end
    xlim([0 5000]);
    xlabel('频率 (Hz)');
    ylabel('幅度');
    axis tight;
    grid on;
    hold off;
end

function mel = freq2mel(freq)
    mel = 2595 * log10(1 + freq / 700);
end

function freq = mel2freq(mel)
    freq = 700 * (10.^(mel / 2595) - 1);
end
