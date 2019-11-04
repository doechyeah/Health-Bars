# Health Bars : Musical mental and physical exercise for those who suffer from Parkinsons disease.

Parkinsons is a progressive neural disorder that restricts muscular contorl. Research has shown that music and exercise is helpful in reducing the progression by increasing dopamine levels and Health bars is aimed to provide a meaningful application that encorporates both of these activities.

Health Bars is an open source project for CMPT 275 on iOS.

- Note: Activities included and features have not been guarenteed to help with symptoms and is created as a proof of concept that can/cannot provide meaningful help for people affected by Parkinsons.

## Features

Musically directed interactive games that are aimed towards the control of rythym and fine motor control.
Leaderboard/Progression charts to measure progress/regression and add as a competitive incentive.
Rotating daily roster of games/activities aimed towards mental and physical musical engagment.

## Build Requirements
requires xcode 10.3
if using other xcode version, audiokit version must be compatible, must manually download and place in project folder

### Project Build Instructions
files:
git clone https://www.github.com/doechyeah/Health-Bars health-bars
cd health-bars
cd "Health Bars"
build will fetch audiokit framework from web

xcode:
open .xcodeproj file
click root project item in left side menu
choose development team
choose simulator in top right
click play icon

cmdline (only works for simulator unless you sign):
build_path="your/outputfolder/here"
xcodebuild -scheme "Health Bars" build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED="NO" CODE_SIGNING_ALLOWED="NO" CONFIGURATION_BUILD_DIR="${build_path}"  -sdk iphonesimulator
start iphone simulator
xcrun simctl list
find device that has (Booted) at the end, ex: (D633C2D0-7633-48A1-8B88-3797C93E946C) (Booted)
copy UUID, ex "D633C2D0-7633-48A1-8B88-3797C93E946C"
xcrun simctl install "paste UUID here" "${build_path}/Health Bars.app"
swipe right to find app installed


### User Requirements
The user is given a set of activities that are musically related to help by musical therapy and excercise in fine motor contorl. They will be incentivized by the scores they achieve in the activities and tracking their progress compared to others on a leaderboard.

## Website
https://advanture.wixsite.com/health-bars-g9

## Testing Framework
Qase test account:
email: shyprea2@hotmail.com
password: healthbars

## Research
[1] J. Jankovic, "Parkinson’s disease: clinical features and diagnosis," Journal of Neurology,
Neurosurgery & Psychiatry, vol. 79, no. 4, p. 368, March, 2008. [Online serial].
Available: https://jnnp.bmj.com/content/79/4/368.full. [Accessed Sept. 20, 2019].
[2] S. Sapir, J. L. Spielman, L. O. Ramig, B. H. Story, and C. Fox, "Effects of Intensive
Voice Treatment (the Lee Silverman Voice Treatment [LSVT]) on Vowel Articulation in
Dysarthric Individuals With Idiopathic Parkinson Disease: Acoustic and Perceptual
Findings," Journal of Speech, Language, and Hearing Research, vol. 50, no. 4, Aug.
2007. [Abstract]. doi: 10.1044/1092-4388(2007/064).
[3] M.J. de Dreua, A.S.D. van der Wilka, E. Poppea, G. Kwakkelb, and E.E.H. van Wegen,
"Rehabilitation, exercise therapy and music in patients with Parkinson's disease: a
meta-analysis of the effects of music-based movement therapy on walking ability,
balance and quality of life," Parkinsonism & Related Disorders, vol. 18, supplement. 1,
pp. S114-S119, Jan. 2008. [Online serial]. doi: 10.1016/S1353-8020(11)70036-0.
[4] N. García-Casares, J. E. Martín-Colom, and J A García-Arnés, "Music Therapy in
Parkinson's Disease," Journal of the American Medical Directors Association, vol. 19,
no. 4, pp. 1054, Dec. 2018. [Abstract]. doi: 10.1016/j.jamda.2018.09.025.
[5] M. S. Bryant, C. D. Workman, F. Jamal, H. Meng, and G. R. Jackson, "Feasibility study:
Effect of hand resistance exercise on handwriting in Parkinson's disease and essential
tremor," Journal of Hand Therapy, vol. 31, no. 1, pp. 29, Mar. 2018. [Abstract]. doi:
10.1016/j.jht.2017.01.002.
[6] C. Pacchetti, F. Mancini, R. Aglieri. C. Fundarò, E. Martignoni, and G. Nappi, "Active
Music Therapy in Parkinson’s Disease: An Integrative Method for Motor and Emotional
Rehabilitation," Psychosomatic Medicine, vol. 62, no. 3, pp. 386, May-Jun. 2000,
[Abstract]. doi: 10.1097/00006842-200005000-00012.
[7] I. Sommerville, “Project Management” in Software Engineering, 10th ed. London,
England: Pearson Education, 2016.
[8] Healthcare Associated Infection Task Force, “NHSScotland model for organisational risk
management” in The Risk Management of HAI: A Methodology for NHSScotland. 2008,
ch. 3, sec. 3.4, pp. 6-7. [Online]. Available: https://www.gov.scot/publications
/risk-management-hai-methodology-nhsscotland/pages/3/
