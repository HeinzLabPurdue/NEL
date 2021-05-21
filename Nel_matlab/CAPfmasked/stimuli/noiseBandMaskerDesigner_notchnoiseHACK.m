classdef noiseBandMaskerDesigner_notchnoiseHACK < matlab.apps.AppBase
    % small GUI for the creation of maskers with multiple bands.
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        GridLayout      matlab.ui.container.GridLayout
        GridLayout2     matlab.ui.container.GridLayout
        GridLayout3     matlab.ui.container.GridLayout
        nbandsLabel     matlab.ui.control.Label
        nbandsSpinner   matlab.ui.control.Spinner
        
        
        TabGroup       matlab.ui.container.TabGroup
        
        maxTabs=0
        BandTabComponents = {}
        BandTabParams = {}
%Components in each tab: (not exhaustive list)
%         Band1Tab        matlab.ui.container.Tab
%         TabGridLayout     matlab.ui.container.GridLayout
%         
%         TabGridLayout2     matlab.ui.container.GridLayout
%         TabGridLayout3     matlab.ui.container.GridLayout
%         
%         TabGridLayout4     matlab.ui.container.GridLayout
%         TabGridLayout5     matlab.ui.container.GridLayout
%         
%         TabGridLayout6    matlab.ui.container.GridLayout
%         TabGridLayout7    matlab.ui.container.GridLayout
%         
%         cutofffreqleftSlider          matlab.ui.control.Slider
%         cutofffreqleftkHzEditFieldLabel  matlab.ui.control.Label
%         cutofffreqleftkHzEditField  matlab.ui.control.NumericEditField
%         
%         cutofffreqrightSlider          matlab.ui.control.Slider
%         cutofffreqrightkHzEditFieldLabel  matlab.ui.control.Label
%         cutofffreqrightkHzEditField  matlab.ui.control.NumericEditField
%         
%         amplitudeSlider          matlab.ui.control.Slider
%         amplitudeEditFieldLabel  matlab.ui.control.Label
%         amplitudeEditField  matlab.ui.control.NumericEditField
        
        GridLayout4     matlab.ui.container.GridLayout
        GridLayout5     matlab.ui.container.GridLayout
        UIAxes          matlab.ui.control.UIAxes
        GridLayout6     matlab.ui.container.GridLayout
        GridLayout7     matlab.ui.container.GridLayout
        
        NameEditFieldLabel          matlab.ui.control.Label
        NameEditField               matlab.ui.control.EditField
        ChooseFolderButton  matlab.ui.control.Button
        GenerateButton  matlab.ui.control.Button
        
        npic=0;
        dirpath=pwd;
    end

    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: nbandsSpinner
        function nbandsSpinnerValueChanged(app, event)
            
            value=app.nbandsSpinner.Value;
            
            if value==0 || ~isempty(app.BandTabComponents{value}.Band1Tab.Parent) %value has been decremented
                app.BandTabComponents{value+1}.Band1Tab.Parent=[];
            else
                app.BandTabComponents{value}.Band1Tab.Parent=app.TabGroup;
                app.TabGroup.SelectedTab=app.BandTabComponents{value}.Band1Tab;
                if value>1  %cut off left>cut off right previous band
                     app.BandTabComponents{value}.cutofffreqleftSlider.Value = ...
                         app.BandTabComponents{value-1}.cutofffreqrightSlider.Value;
                     app.cutofffreqleftSliderValueChanged([])
                end
            end
            
            app.plotBands();
        end
        
        
        function ntab = currentTab(app)
            ntab = app.TabGroup.SelectedTab.UserData.index;
            
        end
        
        
       function cutofffreqleftSliderValueChanged(app, event)
            ntab=app.currentTab();
            app.BandTabParams{ntab}.fleft=app.BandTabComponents{ntab}.cutofffreqleftSlider.Value;
            updateLinkedFreqs(app)
            cutofffreqValueChanged(app, ntab)
            
        end
        
        
        function cutofffreqleftEditFieldValueChanged(app, event)
            ntab=app.currentTab();
            app.BandTabParams{ntab}.fleft=app.BandTabComponents{ntab}.cutofffreqleftkHzEditField.Value;
            updateLinkedFreqs(app)
            cutofffreqValueChanged(app, ntab)
        end
        
        
        
        
       function cutofffreqrightSliderValueChanged(app, event)
            ntab=app.currentTab();
            app.BandTabParams{ntab}.fright=app.BandTabComponents{ntab}.cutofffreqrightSlider.Value;
            updateLinkedFreqs(app);
            cutofffreqValueChanged(app, ntab)
        end
        
        
        function cutofffreqrightEditFieldValueChanged(app, event)
            ntab=app.currentTab();
            app.BandTabParams{ntab}.fright=app.BandTabComponents{ntab}.cutofffreqrightkHzEditField.Value;
            updateLinkedFreqs(app);
            cutofffreqValueChanged(app, ntab)
        end
        
         function deltafSpinnerValueChanged(app, event)
            ntab=app.currentTab();
            fc=app.BandTabComponents{ntab}.fckHzEditField.Value;
            delta_f=app.BandTabComponents{ntab}.deltafSpinner.Value;
            app.BandTabParams{ntab}.fleft=fc-delta_f/2;
            app.BandTabParams{ntab}.fright=fc+delta_f/2;
            updateLinkedFreqs(app)
            cutofffreqValueChanged(app, ntab)
            
        end    
        
        function fckHzEditFieldValueChanged(app, event)
            ntab=app.currentTab();
            fc=app.BandTabComponents{ntab}.fckHzEditField.Value;
            delta_f=app.BandTabComponents{ntab}.deltafSpinner.Value;
            app.BandTabParams{ntab}.fleft=fc-delta_f/2;
            app.BandTabParams{ntab}.fright=fc+delta_f/2;
            updateLinkedFreqs(app)
            cutofffreqValueChanged(app, ntab)
            
        end    
        
        
        
        function cutofffreqValueChanged(app, ntab)  %after an update of fleft/fright
            %fleft
            app.BandTabParams{ntab}.fleft=round(app.BandTabParams{ntab}.fleft,4);
            slider=app.BandTabComponents{ntab}.cutofffreqleftSlider;
            editField=app.BandTabComponents{ntab}.cutofffreqleftkHzEditField;
            
            slider.Value=min(max(app.BandTabParams{ntab}.fleft, slider.Limits(1)), slider.Limits(2));
            editField.Value=app.BandTabParams{ntab}.fleft;
            

            %fright
            app.BandTabParams{ntab}.fright=round(app.BandTabParams{ntab}.fright,4);
            slider=app.BandTabComponents{ntab}.cutofffreqrightSlider;
            editField=app.BandTabComponents{ntab}.cutofffreqrightkHzEditField;

            slider.Value=min(max(app.BandTabParams{ntab}.fright, slider.Limits(1)), slider.Limits(2));
            editField.Value=app.BandTabParams{ntab}.fright;
            
            %fc/delta_f
            fceditField=app.BandTabComponents{ntab}.fckHzEditField;
            deltafSpinner=app.BandTabComponents{ntab}.deltafSpinner;
            
            fceditField.Value=(app.BandTabParams{ntab}.fright+app.BandTabParams{ntab}.fleft)/2;
            deltafSpinner.Value=(app.BandTabParams{ntab}.fright-app.BandTabParams{ntab}.fleft);
            app.plotBands();
        end
        
        
        function linkCheckboxValueChanged(app, event)
            ntab=app.currentTab();
            fleftckb = app.BandTabComponents{ntab}.fleftcheckbox;
            frightckb = app.BandTabComponents{ntab}.frightcheckbox;
            
            if fleftckb.Value ~= app.BandTabParams{ntab}.linklfreq   %value has changed
                app.BandTabParams{ntab}.linklfreq=fleftckb.Value;
                app.BandTabComponents{ntab-1}.frightcheckbox.Value=fleftckb.Value;
                
            end    
            if ntab < app.maxTabs && (frightckb.Value ~= app.BandTabParams{ntab+1}.linklfreq)   %value has changed
                app.BandTabParams{ntab+1}.linklfreq=frightckb.Value;
                app.BandTabComponents{ntab+1}.fleftcheckbox.Value=frightckb.Value;                
            end    
            updateLinkedFreqs(app);
            app.plotBands();
        end
        
        
        function updateLinkedFreqs(app)  %update fleft/fright according to linked bands
            ntab=app.currentTab(); %we have to check for fright[n-1], fleft/fright[n], fleft[n+1]
            if ntab>1 && app.BandTabParams{ntab}.linklfreq ...
                    && app.BandTabParams{ntab}.fleft ~= app.BandTabParams{ntab-1}.fright %fright[n-1]/fleft[n]
              
                app.BandTabParams{ntab-1}.fright=app.BandTabParams{ntab}.fleft;
                cutofffreqValueChanged(app, ntab-1);
            end    
            
            if ntab<app.maxTabs && app.BandTabParams{ntab+1}.linklfreq ...
                    && app.BandTabParams{ntab+1}.fleft ~= app.BandTabParams{ntab}.fright %fleft[n+1]/fright[n]
                app.BandTabParams{ntab+1}.fleft=app.BandTabParams{ntab}.fright;
                cutofffreqValueChanged(app, ntab+1);
            end    
            
        end
        
        function amplitudeSliderValueChanged(app, event)
            amplitudeValueChanged(app, 'Slider')
        end
        
        
        function amplitudeEditFieldValueChanged(app, event)
            amplitudeValueChanged(app, 'EditField')
        end
        
        
        function amplitudeValueChanged(app, component)
            
            ntab=app.currentTab();
            
            
            %HACK for notch noise -> band 2 modifies band 1 and 3
            if ntab==2
               ntab0=2;
               ntab=1;
            else
               ntab0=ntab;
            end

            slider=app.BandTabComponents{ntab}.amplitudeSlider;
            editField=app.BandTabComponents{ntab}.amplitudeEditField;
            
            slider0=app.BandTabComponents{ntab0}.amplitudeSlider;
            editField0=app.BandTabComponents{ntab0}.amplitudeEditField;
            
            
            if strcmp(component, 'Slider')
                slider.Value=slider0.Value;
                editField0.Value=slider0.Value;
                editField.Value=slider0.Value;
                
                editField.Value=round(editField.Value, 0);
                
                editField0.Value=round(editField.Value, 0);
            elseif strcmp(component, 'EditField')
                editField.Value=round(editField0.Value, 1);
                
                slider.Value=max(min(editField0.Value, slider0.Limits(2)), slider0.Limits(1));
                slider0.Value=max(min(editField0.Value, slider0.Limits(2)), slider0.Limits(1));
            end
            
            app.BandTabParams{ntab}.amp=editField.Value;
            
            
            
            if ntab0==2
                ntab=3;
                slider=app.BandTabComponents{ntab}.amplitudeSlider;
                editField=app.BandTabComponents{ntab}.amplitudeEditField;

                slider0=app.BandTabComponents{ntab0}.amplitudeSlider;
                editField0=app.BandTabComponents{ntab0}.amplitudeEditField;


                if strcmp(component, 'Slider')
                    slider.Value=slider0.Value;
                    editField.Value=slider0.Value;

                    editField.Value=round(editField.Value, 0);
                elseif strcmp(component, 'EditField')
                    editField.Value=round(editField0.Value, 1);
                    slider.Value=max(min(editField0.Value, slider0.Limits(2)), slider0.Limits(1));
                end

                app.BandTabParams{ntab}.amp=editField.Value;
             
                
                
                 pause(0.2)
                 slider0.Value=-60;
                 editField0.Value=-100;
                 app.BandTabParams{ntab0}.amp=editField0.Value;
                
                
            end
           
            
            app.plotBands()
        end

        
        function chooseFolderButtonPushed(app, event)
            if strcmp(app.dirpath, pwd) || strcmp(app.dirpath, [pwd '/stimFiles'])
               dirpath0 = app.dirpath; 
            else
                %find parent folder
               parts = strsplit(app.dirpath, '/');
               parts=parts(1:end-1);
               dirpath0 = join(parts, '/');
               dirpath0 =dirpath0{1};
            end
            newdirpath = uigetdir(dirpath0, 'Location where JSON files will be saved');
            
            if newdirpath ~= 0
                app.dirpath=newdirpath;
                if strcmp(app.NameEditField.Value, '{npic}') || strcmp(app.NameEditField.Value, '')
                    parts = strsplit(app.dirpath, '/');
                    app.NameEditField.Value=['{npic}-' parts{end}];
                end
                app.npic=0;
                
            end
        end
        
        function generateButtonPushed(app, event)
            
            name=utils.transformMaskerName(app.NameEditField.Value, app.BandTabParams, app.npic+1);
            
            stimStruct=utils.createStimStruct(app.nbandsSpinner.Value, app.BandTabParams);
            stimStruct.name=name;
            stimJSON=jsonencode(stimStruct);
            stimJSON=prettyjson.prettyjson(stimJSON);
            
            
            filename=[name '.json'];
            filepath=[app.dirpath '/' filename];
            if isfile(filepath)
                warndlg(['File ' filename ' already exists, please use a different name'], 'File already exists');
            else
                if ~isfolder(app.dirpath)
                    mkdir(app.dirpath);
                end
                fileID = fopen(filepath,'w');
                fprintf(fileID, stimJSON);
                fclose(fileID);
                app.npic=app.npic+1;
            end
        end
        
        function plotBands(app)
            utils.plotBands(app.UIAxes, app.nbandsSpinner.Value, app.BandTabParams);
        end
        
    end

    
    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 450 700];
            app.UIFigure.Name = 'Noise-band Masker Designer';    

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {180, '1x', 50};
            app.GridLayout.Padding = [2 2 2 2];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {35, '1x'};
            app.GridLayout2.Padding = [10 0 10 2];
            app.GridLayout2.Layout.Row = 2;
            app.GridLayout2.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout2);
            app.GridLayout3.ColumnWidth = {60, 50, '1x'};
            app.GridLayout3.RowHeight = {20};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.Padding = [2 2 2 2];

            % Create nbandsLabel
            app.nbandsLabel = uilabel(app.GridLayout3);
            app.nbandsLabel.HorizontalAlignment = 'right';
            app.nbandsLabel.Layout.Row = 1;
            app.nbandsLabel.Layout.Column = 1;
            app.nbandsLabel.Text = 'n-bands';

            maxTabs=8;
            app.maxTabs=maxTabs;
            % Create nbandsSpinner
            app.nbandsSpinner = uispinner(app.GridLayout3);
            app.nbandsSpinner.Layout.Row = 1;
            app.nbandsSpinner.Layout.Column = 2;
            app.nbandsSpinner.Limits=[0 maxTabs];
            app.nbandsSpinner.Value=1;
            app.nbandsSpinner.Editable='off';
            app.nbandsSpinner.ValueChangedFcn = createCallbackFcn(app, @nbandsSpinnerValueChanged, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout2);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = 1;
            
            app.BandTabComponents=cell(1, maxTabs);
            app.BandTabParams=cell(1, maxTabs);
            for ntab=1:maxTabs
                TabComponents={};
                
                fleft=0.2+(ntab-1)*1;
                fright=12;
                amp=-20;
                tabParams0=struct('index', ntab);
                tabParams=struct('index', ntab, 'fleft', fleft, 'fright', fright, 'amp', amp, 'linklfreq', false);
                app.BandTabParams{ntab}=tabParams;
                
                % Create Band1Tab
                TabComponents.Band1Tab = uitab(app.TabGroup);
                TabComponents.Band1Tab.Title = ['Band ' int2str(ntab)];
                TabComponents.Band1Tab.UserData=tabParams0;
                
                % Create TabGridLayout
                TabComponents.TabGridLayout = uigridlayout(TabComponents.Band1Tab);
                TabComponents.TabGridLayout.ColumnWidth = {'1x'};
                TabComponents.TabGridLayout.RowHeight = {'3x', '3x', 35, '2x'};
                TabComponents.TabGridLayout.Padding = [5 3 5 3];

                %LEFT CUT OFF
                % Create TabGridLayout2
                TabComponents.TabGridLayout2 = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout2.ColumnWidth = {'1x'};
                TabComponents.TabGridLayout2.RowHeight = {'1x', 30, 2};
                TabComponents.TabGridLayout2.Padding = [1 0 1 0];
                TabComponents.TabGridLayout2.Layout.Row = 1;
                TabComponents.TabGridLayout2.Layout.Column = 1;

                % Create cutofffreqleftSlider
                TabComponents.cutofffreqleftSlider = uislider(TabComponents.TabGridLayout2);
                TabComponents.cutofffreqleftSlider.Layout.Row = 1;
                TabComponents.cutofffreqleftSlider.Layout.Column = 1;
                TabComponents.cutofffreqleftSlider.Limits = [0 12];
                TabComponents.cutofffreqleftSlider.Value=tabParams.fleft;
                TabComponents.cutofffreqleftSlider.ValueChangedFcn = createCallbackFcn(app, @cutofffreqleftSliderValueChanged, true);
                
                
                % Create TabGridLayout3
                TabComponents.TabGridLayout3 = uigridlayout(TabComponents.TabGridLayout2);
                TabComponents.TabGridLayout3.ColumnWidth = {125, 50, '1x', 135};
                TabComponents.TabGridLayout3.RowHeight = {'1x'};
                TabComponents.TabGridLayout3.Padding = [0 0 0 0];
                TabComponents.TabGridLayout3.Layout.Row=2;
                TabComponents.TabGridLayout3.Layout.Column=1;

                % Create cutofffreqleftkHzEditFieldLabel
                TabComponents.cutofffreqleftkHzEditFieldLabel = uilabel(TabComponents.TabGridLayout3);
                TabComponents.cutofffreqleftkHzEditFieldLabel.Layout.Row = 1;
                TabComponents.cutofffreqleftkHzEditFieldLabel.Layout.Column = 1;
                TabComponents.cutofffreqleftkHzEditFieldLabel.Text = '   cut-off freq. left (kHz)';

                % Create cutofffreqleftkHzEditField
                TabComponents.cutofffreqleftkHzEditField = uieditfield(TabComponents.TabGridLayout3, 'numeric');
                TabComponents.cutofffreqleftkHzEditField.Layout.Row=1;
                TabComponents.cutofffreqleftkHzEditField.Layout.Column=2;
                
                TabComponents.cutofffreqleftkHzEditField.Value=tabParams.fleft;
                TabComponents.cutofffreqleftkHzEditField.ValueChangedFcn = createCallbackFcn(app, @cutofffreqleftEditFieldValueChanged, true);
                
                
                %link fleft and right checkbox
                TabComponents.fleftcheckbox = uicheckbox(TabComponents.TabGridLayout3, 'Text','Link with prev. band',...
                  'Value', 0);
                TabComponents.fleftcheckbox.ValueChangedFcn = createCallbackFcn(app, @linkCheckboxValueChanged, true);
                TabComponents.fleftcheckbox.Layout.Row=1;
                TabComponents.fleftcheckbox.Layout.Column=4;
                TabComponents.fleftcheckbox.Visible = (ntab>1);
                

                %RIGHT CUTOFF

                % Create TabGridLayout4
                TabComponents.TabGridLayout4 = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout4.ColumnWidth = {'1x'};
                TabComponents.TabGridLayout4.RowHeight = {'2x', 30, 6};
                TabComponents.TabGridLayout4.Padding = [1 0 1 0];
                TabComponents.TabGridLayout4.Layout.Row = 2;
                TabComponents.TabGridLayout4.Layout.Column = 1;

                % Create cutofffreqrightSlider
                TabComponents.cutofffreqrightSlider = uislider(TabComponents.TabGridLayout4);
                TabComponents.cutofffreqrightSlider.Layout.Row = 1;
                TabComponents.cutofffreqrightSlider.Layout.Column = 1;
                TabComponents.cutofffreqrightSlider.Limits = [0 12];
                TabComponents.cutofffreqrightSlider.Value=tabParams.fright;
                TabComponents.cutofffreqrightSlider.ValueChangedFcn = createCallbackFcn(app, @cutofffreqrightSliderValueChanged, true);
                

                % Create TabGridLayout5
                TabComponents.TabGridLayout5 = uigridlayout(TabComponents.TabGridLayout4);
                TabComponents.TabGridLayout5.ColumnWidth = {132, 50, '1x', 135};
                TabComponents.TabGridLayout5.RowHeight = {'1x'};
                TabComponents.TabGridLayout5.Padding = [0 0 0 0];
                TabComponents.TabGridLayout5.Layout.Row=2;
                TabComponents.TabGridLayout5.Layout.Column=1;

                % Create cutofffreqrightkHzEditFieldLabel
                TabComponents.cutofffreqrightkHzEditFieldLabel = uilabel(TabComponents.TabGridLayout5);
                TabComponents.cutofffreqrightkHzEditFieldLabel.Layout.Row = 1;
                TabComponents.cutofffreqrightkHzEditFieldLabel.Layout.Column = 1;
                TabComponents.cutofffreqrightkHzEditFieldLabel.Text = '   cut-off freq. right (kHz)';

                % Create cutofffreqrightkHzEditField
                TabComponents.cutofffreqrightkHzEditField = uieditfield(TabComponents.TabGridLayout5, 'numeric');
                TabComponents.cutofffreqrightkHzEditField.Layout.Row=1;
                TabComponents.cutofffreqrightkHzEditField.Layout.Column=2;
                TabComponents.cutofffreqrightkHzEditField.Value=tabParams.fright;
                TabComponents.cutofffreqrightkHzEditField.ValueChangedFcn = createCallbackFcn(app, @cutofffreqrightEditFieldValueChanged, true);
                
                %link fleft and fright checkbox
                TabComponents.frightcheckbox = uicheckbox(TabComponents.TabGridLayout5, 'Text','Link with next band',...
                  'Value', 0);
                TabComponents.frightcheckbox.ValueChangedFcn = createCallbackFcn(app, @linkCheckboxValueChanged, true);
                TabComponents.frightcheckbox.Layout.Row=1;
                TabComponents.frightcheckbox.Layout.Column=4;
 
                TabComponents.frightcheckbox.Visible=(ntab<maxTabs);
                
                
                %FC/ DELTA_F
                
                TabComponents.TabGridLayout5b = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout5b.ColumnWidth = {132, 50, '1x', 100, 60};
                TabComponents.TabGridLayout5b.RowHeight = {'1x'};
                TabComponents.TabGridLayout5b.Padding = [1 1 1 5];
                TabComponents.TabGridLayout5b.Layout.Row = 3;
                TabComponents.TabGridLayout5b.Layout.Column = 1;
                
                
                % Create fckHzEditFieldLabel
                TabComponents.fckHzEditFieldLabel = uilabel(TabComponents.TabGridLayout5b);
                TabComponents.fckHzEditFieldLabel.Layout.Row = 1;
                TabComponents.fckHzEditFieldLabel.Layout.Column = 1;
                TabComponents.fckHzEditFieldLabel.Text = '   center frequency (kHz)';

                % Create fckHzEditField
                TabComponents.fckHzEditField = uieditfield(TabComponents.TabGridLayout5b, 'numeric');
                TabComponents.fckHzEditField.Layout.Row=1;
                TabComponents.fckHzEditField.Layout.Column=2;
                TabComponents.fckHzEditField.Value=(tabParams.fleft+tabParams.fright)/2;
                TabComponents.fckHzEditField.ValueChangedFcn = createCallbackFcn(app, @fckHzEditFieldValueChanged, true);
                
                % Create deltafLabel
                TabComponents.deltafLabel = uilabel(TabComponents.TabGridLayout5b);
                TabComponents.deltafLabel.HorizontalAlignment = 'right';
                TabComponents.deltafLabel.Layout.Row = 1;
                TabComponents.deltafLabel.Layout.Column = 4;
                TabComponents.deltafLabel.Text = 'Bandwidth (kHz)';
                
                %Create Delta_f spinner
                TabComponents.deltafSpinner = uispinner(TabComponents.TabGridLayout5b);
                TabComponents.deltafSpinner.Layout.Row = 1;
                TabComponents.deltafSpinner.Layout.Column = 5;
                TabComponents.deltafSpinner.Step=0.1;
                TabComponents.deltafSpinner.Value=(-tabParams.fleft+tabParams.fright);
                TabComponents.deltafSpinner.ValueChangedFcn = createCallbackFcn(app, @deltafSpinnerValueChanged, true);
                


                %AMPLITUDE

                % Create TabGridLayout6
                TabComponents.TabGridLayout6 = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout6.ColumnWidth = {'3x', 150, '2x'};
                TabComponents.TabGridLayout6.RowHeight = {'1x'};
                TabComponents.TabGridLayout6.Padding = [1 1 1 1];
                TabComponents.TabGridLayout6.Layout.Row = 4;
                TabComponents.TabGridLayout6.Layout.Column = 1;

                % Create TabGridLayout7
                TabComponents.TabGridLayout7 = uigridlayout(TabComponents.TabGridLayout6);
                TabComponents.TabGridLayout7.ColumnWidth = {40, 90};
                TabComponents.TabGridLayout7.RowHeight = {'1x', 30, '1x'};
                TabComponents.TabGridLayout7.Padding = [1 1 1 1];
                TabComponents.TabGridLayout7.Layout.Row = 1;
                TabComponents.TabGridLayout7.Layout.Column = 2;


                % Create amplitudeSlider
                TabComponents.amplitudeSlider = uislider(TabComponents.TabGridLayout6);
                TabComponents.amplitudeSlider.Layout.Row = 1;
                TabComponents.amplitudeSlider.Layout.Column = 1;
                TabComponents.amplitudeSlider.Limits = [-60 0];
                %TabComponents.amplitudeSlider.MajorTicks=(-4:0)*20;
                TabComponents.amplitudeSlider.Value = tabParams.amp;
                
                TabComponents.amplitudeSlider.ValueChangedFcn = createCallbackFcn(app, @amplitudeSliderValueChanged, true);
                

                % Create amplitudeEditFieldLabel
                TabComponents.amplitudeEditFieldLabel = uilabel(TabComponents.TabGridLayout7);
                TabComponents.amplitudeEditFieldLabel.Layout.Row = 2;
                TabComponents.amplitudeEditFieldLabel.Layout.Column = 2;
                TabComponents.amplitudeEditFieldLabel.Text = 'Amplitude (dB)';

                % Create amplitudeEditField
                TabComponents.amplitudeEditField = uieditfield(TabComponents.TabGridLayout7, 'numeric');
                TabComponents.amplitudeEditField.Layout.Row=2;
                TabComponents.amplitudeEditField.Layout.Column=1;
                TabComponents.amplitudeEditField.Value=tabParams.amp;
                TabComponents.amplitudeEditField.ValueChangedFcn = createCallbackFcn(app, @amplitudeEditFieldValueChanged, true);
                
                %END TAB
                
                TabComponents.Band1Tab.Parent=[]; %hide all tabs
                app.BandTabComponents{ntab}=TabComponents;
                
            end
             app.BandTabComponents{1}.Band1Tab.Parent=app.TabGroup; %add tab1
            
            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'1x', '4x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Padding = [2 2 2 2];
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 1;

%             % Create GridLayout5
%             app.GridLayout5 = uigridlayout(app.GridLayout4);
%             app.GridLayout5.ColumnWidth = {'1x'};
%             app.GridLayout5.RowHeight = {'1x'};
%             app.GridLayout5.Layout.Row = 1;
%             app.GridLayout5.Layout.Column = 2;
            
            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout4);
            title(app.UIAxes, 'Frequency view')
            xlabel(app.UIAxes, 'f (kHz)')
            ylabel(app.UIAxes, 'Amp (dB)')
            app.UIAxes.XLim = [0 12.5];
            app.UIAxes.YLim = [-40 10];
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'2x', 40, '1x', '2x'};
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Padding = [10 10 10 2];
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;

            % Create NameEditFieldLabel
            app.NameEditFieldLabel = uilabel(app.GridLayout6);
            app.NameEditFieldLabel.HorizontalAlignment = 'right';
            app.NameEditFieldLabel.Layout.Row = 1;
            app.NameEditFieldLabel.Layout.Column = 2;
            app.NameEditFieldLabel.Text = 'Name';

            % Create NameEditField
            app.NameEditField = uieditfield(app.GridLayout6, 'text');
            app.NameEditField.Layout.Row = 1;
            app.NameEditField.Value='{npic}';
            app.NameEditField.Layout.Column = 3;
            
            
            % Create ChooseFolderButton
            app.ChooseFolderButton = uibutton(app.GridLayout6, 'push');
            app.ChooseFolderButton.Text = 'Choose Folder';
            app.ChooseFolderButton.Layout.Row = 1;
            app.ChooseFolderButton.Layout.Column = 1;
            app.ChooseFolderButton.ButtonPushedFcn =  createCallbackFcn(app, @chooseFolderButtonPushed, true);
                
            if isfolder([pwd '/stimFiles'])
                app.dirpath=[pwd '/stimFiles'];
            else
                app.dirpath=pwd;
            end
        
            % Create GenerateButton
            app.GenerateButton = uibutton(app.GridLayout6, 'push');
            app.GenerateButton.Text = 'Generate';
            app.GenerateButton.Layout.Row = 1;
            app.GenerateButton.Layout.Column = 4;
            app.GenerateButton.ButtonPushedFcn =  createCallbackFcn(app, @generateButtonPushed, true);
                
        
            app.plotBands();
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
            
            
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = noiseBandMaskerDesigner_notchnoiseHACK

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end