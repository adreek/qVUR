#### How does the application work?

This application grades vesicoureteral reflux (VUR) from anterior-posterior x-ray scans of voiding cystorethrogram (VCUG) from the following four variables: ureteropelvic junction (UPJ) width, ureterovesical junction (UVJ) width, the maximum ureter width, and tortuosity in a unitless fashion. The application is based on images graded by the international VUR grading system (1) and described further (2).

#### How to use the application?
**Step 0 - Upload your VCUG in either .jpg or .png format, and choose only one ureter (i.e. right or left side) for the following steps**
 <br>*Step 1 - Draw a path from the UPJ to the UVJ,* this will be used to calculate the path length of the ureter and the normalization distance (the direct distance between the UVJ and UPJ on the image), and <b>tortuosity</b> is calculated from the path length divided by the normalization distance.
<br>**Step 2 - Click the two points for the edges of the UPJ,** this will be divided by the normalization distance from the Step 1 to calculate the <b>normalized UPJ width </b>
<br>**Step 3 - Click the two points for the edges of the UVJ,** this will be divided by the normalization distance from the Step 1 to calculate the <b>normalized UVJ width </b>
<br>**Step 4 - Click the two points for the edges of the ureter at the point where the ureter width is largest,** this will be divided by the normalization distance from the Step 1 to calculate the <b>normalized max. ureter width </b>
<br>**Step 5 - Click Grade VUR,** and the application will run through a decision-tree (described below) that will predict the grade of VUR for that renal side.
<br>**If required, Step 6 - Refresh and Restart Application and above steps for contralateral VCUG if present.**

<br>

<img src="https://www.dropbox.com/s/opqmqiy7bz3i0gj/TutorialVURSteps.png?raw=1" alt="Steps to use application to grade VUR with paths highlighted."  width="100%" height="auto">

<br>
<br>

#### Disclaimers
1. This application is meant to supplement clinical judgement and not inform it.
<br> 2. This application is based on a supervised machine learning model, and not on a large training set.
<br> 3. This application does not store any data in either text or image form.

#### References
1. Lebowitz RL, Olbing H, Parkkulainen KV, Smellie JM, Tamminen-Möbius TE. International system of radiographic grading of vesicoureteric reflux. Pediatric radiology. 1985 Feb 1;15(2):105-9.
2. Khondker A, Kwong J, Rickard M, Erdman L, Skreta M, Keefe DT, Lorenzo A. Machine learning for quantitative grading of vesicoureteral reflux in voiding cystourethrograms: Methods and Proof of Concept. Journal of Pediatric Urology, in press (DOI: 10.1016/j.jpurol.2021.10.009).
