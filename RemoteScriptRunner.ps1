# ============================================================
#  Remote Script Runner — PowerShell WPF GUI
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# -------------------------------------------------------
# CONFIGURATION
# -------------------------------------------------------
$ScriptsFolder = Join-Path $PSScriptRoot "Scripts"


# -------------------------------------------------------
# XAML UI DEFINITION
# -------------------------------------------------------
[xml]$XAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Remote Script Runner"
    Width="700" Height="740"
    MinHeight="400"
    MinWidth="600"
    WindowStartupLocation="CenterScreen"
    Background="#0D0D0F"
    FontFamily="Consolas">

    <Window.Resources>

        <Style x:Key="ScrollBarThumb" TargetType="Thumb">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Thumb">
                        <Border Background="#3A7BD5" CornerRadius="2" Margin="2"/>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#5A9BF5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="8"/>
            <Setter Property="Background" Value="#1A1A1E"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="#1A1A1E">
                            <Track x:Name="PART_Track" IsDirectionReversed="True">
                                <Track.Thumb>
                                    <Thumb Style="{StaticResource ScrollBarThumb}"/>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <ControlTemplate x:Key="ComboBoxToggleButton" TargetType="ToggleButton">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition/>
                    <ColumnDefinition Width="28"/>
                </Grid.ColumnDefinitions>
                <Border Grid.ColumnSpan="2"
                        Background="#1A1A1E"
                        BorderBrush="#2E2E38"
                        BorderThickness="1"
                        CornerRadius="3"/>
                <Path Grid.Column="1"
                      HorizontalAlignment="Center"
                      VerticalAlignment="Center"
                      Data="M 0 0 L 6 6 L 12 0 Z"
                      Fill="#3A7BD5"/>
            </Grid>
        </ControlTemplate>

        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#1A1A1E"/>
            <Setter Property="Foreground" Value="#E0E0E8"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="10,0,0,0"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ComboBox">
                        <Grid>
                            <ToggleButton
                                Template="{StaticResource ComboBoxToggleButton}"
                                IsChecked="{Binding Path=IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}, Mode=TwoWay}"/>
                            <ContentPresenter
                                Margin="12,0,30,0"
                                VerticalAlignment="Center"
                                Content="{TemplateBinding SelectionBoxItem}"
                                ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}"/>
                            <Popup
                                IsOpen="{TemplateBinding IsDropDownOpen}"
                                AllowsTransparency="True"
                                Focusable="False"
                                PopupAnimation="Slide">
                                <Grid MinWidth="{TemplateBinding ActualWidth}" MaxHeight="250">
                                    <Border
                                        Background="#1A1A1E"
                                        BorderBrush="#3A7BD5"
                                        BorderThickness="1"
                                        CornerRadius="3">
                                        <ScrollViewer>
                                            <StackPanel IsItemsHost="True"/>
                                        </ScrollViewer>
                                    </Border>
                                </Grid>
                            </Popup>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ComboBoxItem">
                        <Setter Property="Foreground" Value="#E0E0E8"/>
                        <Setter Property="Background" Value="#1A1A1E"/>
                        <Setter Property="Padding" Value="12,8"/>
                        <Setter Property="FontFamily" Value="Consolas"/>
                        <Setter Property="FontSize" Value="13"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ComboBoxItem">
                                    <Border Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}">
                                        <ContentPresenter/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsHighlighted" Value="True">
                                            <Setter Property="Background" Value="#252530"/>
                                            <Setter Property="Foreground" Value="#5A9BF5"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="DarkTextBox" TargetType="TextBox">
            <Setter Property="Background" Value="#1A1A1E"/>
            <Setter Property="Foreground" Value="#E0E0E8"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CaretBrush" Value="#3A7BD5"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Padding" Value="10,0"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="VerticalContentAlignment" Value="Center"/>
            <Style.Triggers>
                <Trigger Property="IsFocused" Value="True">
                    <Setter Property="BorderBrush" Value="#3A7BD5"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="#3A7BD5"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                CornerRadius="3"
                                Padding="18,0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#5A9BF5"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#2A5BAA"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Background" Value="#2A2A35"/>
                                <Setter Property="Foreground" Value="#555565"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SecondaryButton" TargetType="Button">
            <Setter Property="Background" Value="#1A1A1E"/>
            <Setter Property="Foreground" Value="#A0A0B0"/>
            <Setter Property="BorderBrush" Value="#2E2E38"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontFamily" Value="Consolas"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="3"
                                Padding="14,0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#252530"/>
                                <Setter Property="BorderBrush" Value="#3A7BD5"/>
                                <Setter Property="Foreground" Value="#E0E0E8"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Grid Margin="0">

        <Border Height="56" VerticalAlignment="Top"
                Background="#111116"
                BorderBrush="#1E1E28"
                BorderThickness="0,0,0,1">
            <Grid>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="24,0">
                    <Border Width="28" Height="28" Background="#3A7BD5" CornerRadius="4" Margin="0,0,12,0">
                        <TextBlock Text="&#9658;" Foreground="White" FontSize="12"
                                   HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                    <TextBlock Text="REMOTE SCRIPT RUNNER"
                               Foreground="#E0E0E8"
                               FontSize="14"
                               FontWeight="Bold"
                               VerticalAlignment="Center"/>
                </StackPanel>
                <TextBlock x:Name="StatusBadge"
                           Text="● READY"
                           Foreground="#2ECC71"
                           FontSize="11"
                           HorizontalAlignment="Right"
                           VerticalAlignment="Center"
                           Margin="0,0,24,0"/>
            </Grid>
        </Border>

        <Grid Margin="28,66,28,16">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>  <!-- 0: Script dropdown -->
                <RowDefinition Height="Auto"/>  <!-- 1: Script info -->
                <RowDefinition Height="16"/>    <!-- 2: Divider -->
                <RowDefinition Height="Auto"/>  <!-- 3: Ad-hoc command -->
                <RowDefinition Height="16"/>    <!-- 4: Divider -->
                <RowDefinition Height="Auto"/>  <!-- 5: Hostname -->
                <RowDefinition Height="Auto"/>  <!-- 6: Ping result -->
                <RowDefinition Height="16"/>    <!-- 7: Divider -->
                <RowDefinition Height="Auto"/>  <!-- 8: Credentials -->
                <RowDefinition Height="16"/>    <!-- 9: Divider -->
                <RowDefinition Height="Auto"/>  <!-- 10: Buttons -->
                <RowDefinition Height="16"/>    <!-- 11: Spacer -->
                <RowDefinition Height="*"/>     <!-- 12: Output -->
            </Grid.RowDefinitions>

            <!-- SCRIPT DROPDOWN -->
            <StackPanel Grid.Row="0">
                <TextBlock Text="SCRIPT" Foreground="#555565" FontSize="10" Margin="0,0,0,6"/>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="10"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <ComboBox x:Name="ScriptComboBox" Grid.Column="0"/>
                    <Button x:Name="RefreshButton" Grid.Column="2"
                            Style="{StaticResource SecondaryButton}"
                            Width="38" ToolTip="Refresh list">
                        <TextBlock Text="&#8635;" FontSize="16" Foreground="#3A7BD5"/>
                    </Button>
                </Grid>
            </StackPanel>

            <!-- SCRIPT INFO -->
            <Border Grid.Row="1"
                    Background="#111116"
                    BorderBrush="#1E1E28"
                    BorderThickness="1"
                    CornerRadius="3"
                    Margin="0,8,0,0"
                    Padding="12,10"
                    MinHeight="36">
                <TextBlock x:Name="ScriptInfoText"
                           Text="No script selected."
                           Foreground="#444454"
                           FontSize="12"
                           TextWrapping="Wrap"/>
            </Border>

            <Border Grid.Row="2" Height="1" Background="#1E1E28" VerticalAlignment="Center"/>

            <!-- AD-HOC COMMAND -->
            <StackPanel Grid.Row="3">
                <TextBlock Text="AD-HOC COMMAND  (This will be executed if the text box is not empty!)" Foreground="#555565" FontSize="10" Margin="0,0,0,6"/>
                <TextBox x:Name="AdHocCommandBox"
                         Background="#1A1A1E"
                         Foreground="#E0E0E8"
                         BorderBrush="#2E2E38"
                         BorderThickness="1"
                         CaretBrush="#3A7BD5"
                         FontFamily="Consolas"
                         FontSize="13"
                         Padding="10,8"
                         Height="90"
                         AcceptsReturn="True"
                         TextWrapping="Wrap"
                         VerticalScrollBarVisibility="Auto"
                         VerticalContentAlignment="Top"
                         ToolTip="Pl.: Get-CimInstance Win32_Processor — Enter = új sor, Ctrl+Enter = futtatás"/>
            </StackPanel>

            <Border Grid.Row="4" Height="1" Background="#1E1E28" VerticalAlignment="Center"/>

            <!-- HOSTNAME -->
            <StackPanel Grid.Row="5">
                <TextBlock Text="TARGET HOSTNAME / IP" Foreground="#555565" FontSize="10" Margin="0,0,0,6"/>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="10"/>
                        <ColumnDefinition Width="120"/>
                    </Grid.ColumnDefinitions>
                    <TextBox x:Name="HostnameTextBox"
                             Grid.Column="0"
                             Style="{StaticResource DarkTextBox}"
                             ToolTip="Machine name or IP address"/>
                    <Button x:Name="PingButton" Grid.Column="2"
                            Style="{StaticResource SecondaryButton}"
                            Content="PING TEST"
                            FontSize="11"/>
                </Grid>
            </StackPanel>

            <TextBlock x:Name="PingResult" Grid.Row="6"
                       Text="" FontSize="11"
                       Margin="2,4,0,0"
                       Foreground="#555565"/>

            <Border Grid.Row="7" Height="1" Background="#1E1E28" VerticalAlignment="Center"/>

            <!-- CREDENTIALS -->
            <StackPanel Grid.Row="8">
                <TextBlock Text="RUN AS" Foreground="#555565" FontSize="10" Margin="0,0,0,6"/>
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="10"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <TextBox x:Name="UsernameBox" Grid.Column="0"
                             Style="{StaticResource DarkTextBox}"
                             ToolTip="Domain\Username"/>
                    <PasswordBox x:Name="PasswordBox" Grid.Column="2"
                                 Height="38"
                                 Background="#1A1A1E"
                                 Foreground="#E0E0E8"
                                 BorderBrush="#2E2E38"
                                 BorderThickness="1"
                                 FontFamily="Consolas"
                                 FontSize="13"
                                 Padding="10,0"
                                 PasswordChar="&#9679;"
                                 VerticalContentAlignment="Center"
                                 ToolTip="Password"/>
                </Grid>
            </StackPanel>

            <Border Grid.Row="9" Height="1" Background="#1E1E28" VerticalAlignment="Center"/>

            <!-- ACTION BUTTONS -->
            <Grid Grid.Row="10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="10"/>
                    <ColumnDefinition Width="145"/>
                    <ColumnDefinition Width="10"/>
                    <ColumnDefinition Width="145"/>
                    <ColumnDefinition Width="10"/>
                    <ColumnDefinition Width="70"/>
                </Grid.ColumnDefinitions>
                <Button x:Name="RunButton" Grid.Column="0"
                        Style="{StaticResource PrimaryButton}"
                        Content="&#9658;   RUN SCRIPT"
                        FontSize="13"/>
                <Button x:Name="OpenScriptFolderButton" Grid.Column="2"
                        Style="{StaticResource SecondaryButton}"
                        Content="Open Script Folder"
                        FontSize="11"/>
                <Button x:Name="OpenOutputFolderButton" Grid.Column="4"
                        Style="{StaticResource SecondaryButton}"
                        Content="Remote Explorer"
                        FontSize="11"/>
                <Button x:Name="ClearButton" Grid.Column="6"
                        Style="{StaticResource SecondaryButton}"
                        Content="CLEAR"
                        FontSize="11"/>
            </Grid>

            <!-- OUTPUT BOX -->
            <Border Grid.Row="12"
                    Background="#0A0A0C"
                    BorderBrush="#1E1E28"
                    BorderThickness="1"
                    CornerRadius="4">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <Border Grid.Row="0"
                            Background="#111116"
                            BorderBrush="#1E1E28"
                            BorderThickness="0,0,0,1"
                            Padding="12,6">
                        <TextBlock Text="OUTPUT" Foreground="#444454" FontSize="10"/>
                    </Border>
                    <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Height="130">
                        <TextBox x:Name="OutputTextBox"
                                 Background="Transparent"
                                 Foreground="#7ABFFF"
                                 BorderThickness="0"
                                 FontFamily="Consolas"
                                 FontSize="12"
                                 IsReadOnly="True"
                                 TextWrapping="Wrap"
                                 Padding="12,8"
                                 AcceptsReturn="True"
                                 Text="&gt; Waiting for execution..."/>
                    </ScrollViewer>
                </Grid>
            </Border>

        </Grid>

    </Grid>
</Window>
"@

# -------------------------------------------------------
# LOAD WINDOW
# -------------------------------------------------------
$Reader = (New-Object System.Xml.XmlNodeReader $XAML)
try {
    $Window = [Windows.Markup.XamlReader]::Load($Reader)
} catch {
    [System.Windows.MessageBox]::Show("XAML load error:`n$_", "Error", "OK", "Error")
    exit
}

# Get controls
$ScriptComboBox         = $Window.FindName("ScriptComboBox")
$AdHocCommandBox        = $Window.FindName("AdHocCommandBox")
$HostnameTextBox        = $Window.FindName("HostnameTextBox")
$UsernameBox            = $Window.FindName("UsernameBox")
$PasswordBox            = $Window.FindName("PasswordBox")
$RunButton              = $Window.FindName("RunButton")
$RefreshButton          = $Window.FindName("RefreshButton")
$PingButton             = $Window.FindName("PingButton")
$OpenScriptFolderButton = $Window.FindName("OpenScriptFolderButton")
$OpenOutputFolderButton = $Window.FindName("OpenOutputFolderButton")
$ClearButton            = $Window.FindName("ClearButton")
$OutputTextBox          = $Window.FindName("OutputTextBox")
$ScriptInfoText         = $Window.FindName("ScriptInfoText")
$StatusBadge            = $Window.FindName("StatusBadge")
$PingResult             = $Window.FindName("PingResult")

# -------------------------------------------------------
# HELPER FUNCTIONS
# -------------------------------------------------------
function Write-Output-Box {
    param([string]$Text, [string]$Color = "#7ABFFF")
    $OutputTextBox.Dispatcher.Invoke([action]{
        $OutputTextBox.Text += "`n$Text"
        $OutputTextBox.ScrollToEnd()
        $OutputTextBox.Foreground = $Color
    })
}

function Set-Status {
    param([string]$Text, [string]$Color)
    $StatusBadge.Dispatcher.Invoke([action]{
        $StatusBadge.Text       = $Text
        $StatusBadge.Foreground = $Color
    })
}

function Load-Scripts {
    $ScriptComboBox.Items.Clear()
    [void]$ScriptComboBox.Items.Add("— Select a script —")
    if (-not (Test-Path $ScriptsFolder)) {
        New-Item -ItemType Directory -Path $ScriptsFolder -Force | Out-Null
        $ScriptInfoText.Text = "Folder created: $ScriptsFolder"
    }
    $scripts = Get-ChildItem -Path $ScriptsFolder -Filter "*.ps1" -ErrorAction SilentlyContinue
    if ($scripts) {
        foreach ($s in $scripts) {
            [void]$ScriptComboBox.Items.Add($s.Name)
        }
        $ScriptInfoText.Text       = "$($scripts.Count) script(s) found in: $ScriptsFolder"
        $ScriptInfoText.Foreground = "#555565"
    } else {
        $ScriptInfoText.Text       = "No .ps1 files found in: $ScriptsFolder"
        $ScriptInfoText.Foreground = "#E05050"
    }
    $ScriptComboBox.SelectedIndex = 0
}

# -------------------------------------------------------
# EVENT HANDLERS
# -------------------------------------------------------

$RefreshButton.Add_Click({
    Load-Scripts
    Write-Output-Box "> Script list refreshed."
})

$ScriptComboBox.Add_SelectionChanged({
    $sel = $ScriptComboBox.SelectedItem
    if ($sel -and $sel -notlike "*Select a script*") {
        $path = Join-Path $ScriptsFolder $sel
        $ScriptInfoText.Text       = "Path: $path"
        $ScriptInfoText.Foreground = "#3A7BD5"
    } else {
        $ScriptInfoText.Text       = "No script selected."
        $ScriptInfoText.Foreground = "#444454"
    }
})

$OpenScriptFolderButton.Add_Click({
    if (-not (Test-Path $ScriptsFolder)) { New-Item -ItemType Directory -Path $ScriptsFolder -Force | Out-Null }
    Start-Process explorer.exe $ScriptsFolder
})

$OpenOutputFolderButton.Add_Click({
    $hostname = $HostnameTextBox.Text.Trim()
    $username = $UsernameBox.Text.Trim()
    $password = $PasswordBox.Password
    cmd.exe /c "net use \\$hostname\C$ $password /user:$username"
    Start-Process explorer.exe "\\$hostname\C$"
})

$ClearButton.Add_Click({
    $OutputTextBox.Text = "> Output cleared."
    $PingResult.Text    = ""
})

$PingButton.Add_Click({
    $host_val = $HostnameTextBox.Text.Trim()
    if (-not $host_val) {
        $PingResult.Text       = "⚠  Enter a hostname first."
        $PingResult.Foreground = "#E0A030"
        return
    }
    $PingResult.Text       = "⌛  Pinging..."
    $PingResult.Foreground = "#555565"
    $Window.Dispatcher.Invoke([action]{}, "Background")

    $job = Start-Job -ScriptBlock {
        param($h)
        Test-Connection -ComputerName $h -Count 2 -Quiet
    } -ArgumentList $host_val

    $null = Wait-Job $job
    $ok   = Receive-Job $job
    Remove-Job $job

    if ($ok) {
        $PingResult.Text       = "✔  $host_val — REACHABLE"
        $PingResult.Foreground = "#2ECC71"
    } else {
        $PingResult.Text       = "✘  $host_val — UNREACHABLE"
        $PingResult.Foreground = "#E05050"
    }
})

$HostnameTextBox.Add_KeyDown({
    if ($_.Key -eq "Return") { $RunButton.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent)) }
})

# By pressing Ctrl+Enter the script will be executed
$AdHocCommandBox.Add_KeyDown({
    if ($_.Key -eq "Return" -and [System.Windows.Input.Keyboard]::Modifiers -eq [System.Windows.Input.ModifierKeys]::Control) {
        $RunButton.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent))
    }
})

$RunButton.Add_Click({
    $adHocCmd       = $AdHocCommandBox.Text.Trim()
    $selectedScript = $ScriptComboBox.SelectedItem
    $hostname       = $HostnameTextBox.Text.Trim()
    $username       = $UsernameBox.Text.Trim()
    $password       = $PasswordBox.Password


    $runMode = ""
    if ($adHocCmd -ne "") {
        $runMode = "adhoc"
    } elseif ($selectedScript -and $selectedScript -notlike "*Select a script*") {
        $runMode    = "script"
        $scriptPath = Join-Path $ScriptsFolder $selectedScript
    } else {
        [System.Windows.MessageBox]::Show("Please select a script from the list or use the ad-hoc command text box.", "Missing Input", "OK", "Warning")
        return
    }

    if (-not $hostname) {
        [System.Windows.MessageBox]::Show("Please enter a target hostname or IP address.", "Missing Input", "OK", "Warning")
        return
    }

    Set-Status "● RUNNING..." "#F0A030"
    $OutputTextBox.Text = ""

    if ($runMode -eq "adhoc") {
        Write-Output-Box "> [$((Get-Date).ToString('HH:mm:ss'))] Ad-hoc parancs: $adHocCmd"
    } else {
        Write-Output-Box "> [$((Get-Date).ToString('HH:mm:ss'))] Starting: $selectedScript"
    }
    Write-Output-Box "> Target: $hostname"
    Write-Output-Box "> ─────────────────────────────────"
    $RunButton.IsEnabled = $false

    $dispatcher  = $Window.Dispatcher
    $outputBox   = $OutputTextBox
    $statusBadge = $StatusBadge
    $runBtn      = $RunButton

    $bgScript = {
        param($mode, $sp, $adhoc, $hn, $un, $pw, $disp, $outBox, $statBadge, $btn)

        function Append-UI ($text, $hexColor) {
            $t = $text; $c = $hexColor
            $disp.Invoke([action]{
                $outBox.AppendText("`n$t")
                $outBox.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($c)
                $outBox.ScrollToEnd()
            }.GetNewClosure())
        }
        function Status-UI ($text, $hexColor) {
            $t = $text; $c = $hexColor
            $disp.Invoke([action]{
                $statBadge.Text       = $t
                $statBadge.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($c)
            }.GetNewClosure())
        }

        try {
            $cred = $null
            if ($un -ne "") {
                $secPass = ConvertTo-SecureString $pw -AsPlainText -Force
                $cred    = New-Object System.Management.Automation.PSCredential($un, $secPass)
            }

            $service = Get-WmiObject -Computer $hn -Credential $cred -Class Win32_Service -Filter "Name='winrm'"
            $originalStartType = $service.StartMode
            $originalStatus    = $service.State
            $service.StartService() | Out-Null

            if ($mode -eq "adhoc") {
                $scriptBlock = [scriptblock]::Create($adhoc)
            } else {
                $scriptContent  = Get-Content -Path $sp -Raw -ErrorAction Stop
                $wrappedContent = "function Write-Host { param([Parameter(ValueFromPipeline,Position=0)][object]`$Obj,[object]`$ForegroundColor,[object]`$BackgroundColor,[switch]`$NoNewline) process { Write-Output `$Obj } }`n" + $scriptContent
                $scriptBlock    = [scriptblock]::Create($wrappedContent)
            }

            $sessionOpts = @{ ComputerName = $hn; ErrorAction = "Stop" }
            if ($cred) { $sessionOpts.Credential = $cred }
            $session = New-PSSession @sessionOpts

            $hasOutput = $false
            Invoke-Command -Session $session -ScriptBlock $scriptBlock 2>&1 | ForEach-Object {
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $msg = $_.ToString()
                    if ($msg -notlike "*No events were found*" -and
                        $msg -notlike "*no matching events*" -and
                        $msg -notlike "*ObjectNotFound*") {
                        Append-UI "> ! $msg" "#E09040"
                        $hasOutput = $true
                    }
                } else {
                    $line = ($_ | Out-String).TrimEnd()
                    if ($line -ne "") {
                        Append-UI $line "#7ABFFF"
                        $hasOutput = $true
                    }
                }
            }

            $service.ChangeStartMode("$originalStartType") | Out-Null
            if ($originalStatus -eq "Stopped") {
                $service.StopService() | Out-Null
            }

            Remove-PSSession $session -ErrorAction SilentlyContinue

            if (-not $hasOutput) { Append-UI "> (No output returned)" "#555565" }

            Append-UI "> ─────────────────────────────────" "#555565"
            Append-UI "> Completed successfully." "#2ECC71"
            Status-UI "● READY" "#2ECC71"

        } catch {
            $errMsg = $_.ToString()
            if ($errMsg -like "*WinRM*" -or $errMsg -like "*WSMan*") {
                Append-UI "> ERROR: Cannot connect - WinRM not available on target." "#E05050"
                Append-UI "> Tip: Run on target: Enable-PSRemoting -Force" "#888898"
            } elseif ($errMsg -like "*Access*denied*") {
                Append-UI "> ERROR: Access denied - check your credentials." "#E05050"
            } else {
                Append-UI "> ERROR: $errMsg" "#E05050"
            }
            Append-UI "> ─────────────────────────────────" "#E05050"
            Status-UI "● ERROR" "#E05050"
        }

        $disp.Invoke([action]{ $btn.IsEnabled = $true }.GetNewClosure())
    }

    $ps = [PowerShell]::Create()
    [void]$ps.AddScript($bgScript)
    [void]$ps.AddParameter("mode",      $runMode)
    [void]$ps.AddParameter("sp",        $scriptPath)
    [void]$ps.AddParameter("adhoc",     $adHocCmd)
    [void]$ps.AddParameter("hn",        $hostname)
    [void]$ps.AddParameter("un",        $username)
    [void]$ps.AddParameter("pw",        $password)
    [void]$ps.AddParameter("disp",      $dispatcher)
    [void]$ps.AddParameter("outBox",    $outputBox)
    [void]$ps.AddParameter("statBadge", $statusBadge)
    [void]$ps.AddParameter("btn",       $runBtn)

    [void]$ps.BeginInvoke()
})

# -------------------------------------------------------
# START
# -------------------------------------------------------
Load-Scripts
[void]$Window.ShowDialog()
