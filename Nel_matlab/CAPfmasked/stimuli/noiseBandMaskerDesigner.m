classdef noiseBandMaskerDesigner < matlab.apps.AppBase
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
        
        BandTabComponents = {}
        BandTabParams = {}
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
            cutofffreqValueChanged(app, 'Slider', 'left')
        end
        
        
        function cutofffreqleftEditFieldValueChanged(app, event)
            cutofffreqValueChanged(app, 'EditField', 'left')
        end
        
        
       function cutofffreqrightSliderValueChanged(app, event)
            cutofffreqValueChanged(app, 'Slider', 'right')
        end
        
        
        function cutofffreqrightEditFieldValueChanged(app, event)
            cutofffreqValueChanged(app, 'EditField', 'right')
        end
        
        
        function cutofffreqValueChanged(app, component, side)
            ntab=app.currentTab();
            leftBool=false;
            if strcmp(side, 'left')
                leftBool=true;
                slider=app.BandTabComponents{ntab}.cutofffreqleftSlider;
                editField=app.BandTabComponents{ntab}.cutofffreqleftkHzEditField;
            else
                slider=app.BandTabComponents{ntab}.cutofffreqrightSlider;
                editField=app.BandTabComponents{ntab}.cutofffreqrightkHzEditField;
            end
            
            if strcmp(component, 'Slider')
                editField.Value=slider.Value;
                
                editField.Value=round(editField.Value, 2);
            elseif strcmp(component, 'EditField')
                editField.Value=round(editField.Value, 3);
                slider.Value=editField.Value;
            end
            
            if leftBool
                app.BandTabParams{ntab}.fleft=editField.Value;
            else
                app.BandTabParams{ntab}.fright=editField.Value;
            end
            
            app.plotBands()
        end
        
        
        function amplitudeSliderValueChanged(app, event)
            amplitudeValueChanged(app, 'Slider')
        end
        
        
        function amplitudeEditFieldValueChanged(app, event)
            amplitudeValueChanged(app, 'EditField')
        end
        
        
        function amplitudeValueChanged(app, component)
            ntab=app.currentTab();

            slider=app.BandTabComponents{ntab}.amplitudeSlider;
            editField=app.BandTabComponents{ntab}.amplitudeEditField;
            
            
            if strcmp(component, 'Slider')
                editField.Value=slider.Value;
                
                editField.Value=round(editField.Value, 0);
            elseif strcmp(component, 'EditField')
                editField.Value=round(editField.Value, 1);
                slider.Value=editField.Value;
            end
            
            app.BandTabParams{ntab}.amp=editField.Value;
            
            app.plotBands()
        end

        
        function chooseFolderButtonPushed(app, event)
            if strcmp(app.dirpath, pwd) || strcmp(app.dirpath, [pwd '/stimFiles'])
               dirpath0 = app.dirpath; 
            else
                %find parent folder
                app.dirpath
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
            stimStruct.name=name
            stimJSON=jsonencode(stimStruct);
            stimJSON=prettyjson.prettyjson(stimJSON);
            
            
            filename=[name '.json'];
            filepath=[app.dirpath '/' filename];
            if isfile(filepath)
                warndlg(['File ' filename ' already exists, please use a different name'], 'File already exists');
            else
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
                amp=0;
                tabParams0=struct('index', ntab);
                tabParams=struct('index', ntab, 'fleft', fleft, 'fright', fright, 'amp', amp);
                app.BandTabParams{ntab}=tabParams;
                
                % Create Band1Tab
                TabComponents.Band1Tab = uitab(app.TabGroup);
                TabComponents.Band1Tab.Title = ['Band ' int2str(ntab)];
                TabComponents.Band1Tab.UserData=tabParams0;
                
                % Create TabGridLayout
                TabComponents.TabGridLayout = uigridlayout(TabComponents.Band1Tab);
                TabComponents.TabGridLayout.ColumnWidth = {'1x'};
                TabComponents.TabGridLayout.RowHeight = {'1x', '1x', '1x'};
                TabComponents.TabGridLayout.Padding = [5 5 5 5];

                %LEFT CUT OFF
                % Create TabGridLayout2
                TabComponents.TabGridLayout2 = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout2.ColumnWidth = {'1x'};
                TabComponents.TabGridLayout2.RowHeight = {'1x', 30, 3};
                TabComponents.TabGridLayout2.Padding = [1 1 1 1];
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
                TabComponents.TabGridLayout3.ColumnWidth = {'1x', 115, 50, '1x'};
                TabComponents.TabGridLayout3.RowHeight = {'1x'};
                TabComponents.TabGridLayout3.Padding = [0 0 0 0];
                TabComponents.TabGridLayout3.Layout.Row=2;
                TabComponents.TabGridLayout3.Layout.Column=1;

                % Create cutofffreqleftkHzEditFieldLabel
                TabComponents.cutofffreqleftkHzEditFieldLabel = uilabel(TabComponents.TabGridLayout3);
                TabComponents.cutofffreqleftkHzEditFieldLabel.Layout.Row = 1;
                TabComponents.cutofffreqleftkHzEditFieldLabel.Layout.Column = 2;
                TabComponents.cutofffreqleftkHzEditFieldLabel.Text = 'cut-off freq. left (kHz)';

                % Create cutofffreqleftkHzEditField
                TabComponents.cutofffreqleftkHzEditField = uieditfield(TabComponents.TabGridLayout3, 'numeric');
                TabComponents.cutofffreqleftkHzEditField.Layout.Row=1;
                TabComponents.cutofffreqleftkHzEditField.Layout.Column=3;
                
                TabComponents.cutofffreqleftkHzEditField.Value=tabParams.fleft;
                TabComponents.cutofffreqleftkHzEditField.ValueChangedFcn = createCallbackFcn(app, @cutofffreqleftEditFieldValueChanged, true);
                
                

                %RIGHT CUTOFF

                % Create TabGridLayout4
                TabComponents.TabGridLayout4 = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout4.ColumnWidth = {'1x'};
                TabComponents.TabGridLayout4.RowHeight = {'2x', 30, 3};
                TabComponents.TabGridLayout4.Padding = [1 1 1 1];
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
                TabComponents.TabGridLayout5.ColumnWidth = {'1x', 120, 50, '1x'};
                TabComponents.TabGridLayout5.RowHeight = {'1x'};
                TabComponents.TabGridLayout5.Padding = [0 0 0 0];
                TabComponents.TabGridLayout5.Layout.Row=2;
                TabComponents.TabGridLayout5.Layout.Column=1;

                % Create cutofffreqrightkHzEditFieldLabel
                TabComponents.cutofffreqrightkHzEditFieldLabel = uilabel(TabComponents.TabGridLayout5);
                TabComponents.cutofffreqrightkHzEditFieldLabel.Layout.Row = 1;
                TabComponents.cutofffreqrightkHzEditFieldLabel.Layout.Column = 2;
                TabComponents.cutofffreqrightkHzEditFieldLabel.Text = 'cut-off freq. right (kHz)';

                % Create cutofffreqrightkHzEditField
                TabComponents.cutofffreqrightkHzEditField = uieditfield(TabComponents.TabGridLayout5, 'numeric');
                TabComponents.cutofffreqrightkHzEditField.Layout.Row=1;
                TabComponents.cutofffreqrightkHzEditField.Layout.Column=3;
                TabComponents.cutofffreqrightkHzEditField.Value=tabParams.fright;
                TabComponents.cutofffreqrightkHzEditField.ValueChangedFcn = createCallbackFcn(app, @cutofffreqrightEditFieldValueChanged, true);
                


                %AMPLITUDE

                % Create TabGridLayout6
                TabComponents.TabGridLayout6 = uigridlayout(TabComponents.TabGridLayout);
                TabComponents.TabGridLayout6.ColumnWidth = {'3x', 150, '2x'};
                TabComponents.TabGridLayout6.RowHeight = {'1x'};
                TabComponents.TabGridLayout6.Padding = [1 1 1 1];
                TabComponents.TabGridLayout6.Layout.Row = 3;
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
                TabComponents.amplitudeSlider.Value = -20;
                
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
                TabComponents.amplitudeEditField.Value=-20
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
        function app = noiseBandMaskerDesigner

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