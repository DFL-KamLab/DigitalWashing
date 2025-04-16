function [Local_Detectors_Decisions_Binary] = Local_Detectors_Decisions(Locations_and_Features_Foreground, Locations_and_Features_Background, Initial_Frame, Final_Frame, Nbr_Training_Frames, STD_VAL)
%% Local_Detectors_Decisions: Fuse Foreground and Background Local Detections
%
%  This function fuses detections obtained from foreground and background feature 
%  matrices. For each standard deviation multiplier provided in STD_VAL, it computes 
%  valid feature ranges based on the foreground data. Then for each frame (after the 
%  training period), it selects background detections that fall within these valid 
%  ranges. Finally, it appends the corresponding foreground detections for the same 
%  frame. Visual plotting of the detections is included for validation.
%
%  Inputs:
%    Locations_and_Features_Foreground - Matrix containing features for foreground objects.
%                                        Expected columns include features of interest and the frame index.
%    Locations_and_Features_Background - Matrix containing features for background objects.
%                                        Expected columns include features of interest and the frame index.
%    Initial_Frame                     - Index of the first frame processed.
%    Final_Frame                       - Index of the last frame processed.
%    Nbr_Training_Frames               - Number of training frames used for background initialization.
%    STD_VAL                           - Scalar or vector of standard deviation multipliers for thresholding.
%
%  Output:
%    Local_Detectors_Decisions_Binary  - Matrix containing detected object coordinates 
%                                        and their corresponding frame index.
%
%  Notes:
%    - Feature columns used from the foreground matrix: 
%         Column 3: Minor axis length (after abs)
%         Column 5: Minor-major axis ratio
%         Column 6: Hu feature value
%    - Detections are plotted for verification:
%         Background detections: yellow squares labeled 'B'
%         Foreground detections: cyan crosses labeled 'sperm'
%


Local_Detectors_Decisions_Binary = [];

% Loop over each standard deviation multiplier provided in STD_VAL.
for RnG = STD_VAL
    % Calculate acceptable range for the minor axis (column 3) using foreground data.
    Var1 = abs(Locations_and_Features_Foreground(:,3))';  % Feature values (transposed)
    Mu1 = mean(Var1);
    SD1 = std(Var1);
    Range_Minor_Axis = [Mu1 - RnG*SD1, Mu1 + RnG*SD1];

    % Calculate acceptable range for the minor-major axis ratio (column 5).
    Var2 = abs(Locations_and_Features_Foreground(:,5))';
    Mu2 = mean(Var2);
    SD2 = std(Var2);
    Range_Minor_Major_Axis = [Mu2 - RnG*SD2, Mu2 + RnG*SD2];

    % Calculate acceptable range for the Hu features (column 6).
    Var3 = abs(Locations_and_Features_Foreground(:,6))';
    Mu3 = mean(Var3);
    SD3 = std(Var3);
    Range_Hu_Features = [Mu3 - RnG*SD3, Mu3 + RnG*SD3];

    % Process each frame from the end of training to the last frame.
    for j = Initial_Frame + Nbr_Training_Frames : Final_Frame
        % Extract background features corresponding to frame j.
        ChecK1 = Locations_and_Features_Background(Locations_and_Features_Background(:,end) == j, 1:6);
        
        % Determine which background detections have feature values within the valid ranges.
        T1_1 = (ChecK1(:,3) > Range_Minor_Axis(1)) & (ChecK1(:,3) < Range_Minor_Axis(2));
        T2_1 = (ChecK1(:,5) > Range_Minor_Major_Axis(1)) & (ChecK1(:,5) < Range_Minor_Major_Axis(2));
        T3_1 = (ChecK1(:,6) > Range_Hu_Features(1)) & (ChecK1(:,6) < Range_Hu_Features(2));
        T0 = T1_1 & T2_1 & T3_1;

        % Append valid background detections for frame j.
        % Columns 1-2 contain coordinate information; column 3 is set to the frame number.
        Local_Detectors_Decisions_Binary = [Local_Detectors_Decisions_Binary; ...
            [ChecK1(T0, 1:2), j * ones(size(ChecK1(T0, 1:2),1), 1)]];
        
        % Plot background detections for frame j for visual inspection.
        detections_final = Local_Detectors_Decisions_Binary(Local_Detectors_Decisions_Binary(:,3) == j, 1:2);
        if ~isempty(detections_final)
            plot(detections_final(:,1), detections_final(:,2), 'sqr')
            text(detections_final(:,1), detections_final(:,2), 'B', 'Color', 'y')
        end

        % Append foreground detections for frame j.
        % Extract coordinate data from foreground features where the frame index is j.
        Local_Detectors_Decisions_Binary = [Local_Detectors_Decisions_Binary; ...
            [Locations_and_Features_Foreground(Locations_and_Features_Foreground(:,end) == j, 1:2), ...
             j * ones(length(Locations_and_Features_Foreground(Locations_and_Features_Foreground(:,end) == j, 1)), 1)]];
        
        % Plot foreground detections for frame j for visual inspection.
        detections_final = Local_Detectors_Decisions_Binary(Local_Detectors_Decisions_Binary(:,3) == j, 1:2);
        if ~isempty(detections_final)
            plot(detections_final(:,1), detections_final(:,2), 'xc')
            text(detections_final(:,1), detections_final(:,2), 'sperm', 'Color', 'c')
        end
        
        % Optionally, use 'waitforbuttonpress' if interactive debugging is needed.
        % waitforbuttonpress
    end
end

end
