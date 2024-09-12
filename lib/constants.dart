import 'package:flutter/material.dart';

const boardingTitle1 = "Welcome to VoteTrack";
const boardingDescription1 =
    'Conduct elections, view real-time results, and analyze data with ease.';
const boardingLottie1 = 'assets/lottie/1.json';

const boardingTitle2 = "Conduct Elections";
const boardingDescription2 =
    'Create and manage elections effortlessly. Customize settings and invite participants.';
const boardingLottie2 = 'assets/lottie/2.json';

const boardingTitle3 = "View Results";
const boardingDescription3 =
    'Analyze election results with interactive graphical representations in real-time.';
const boardingLottie3 = 'assets/lottie/3.json';

const logoImage = "assets/v.png";
const loginText = "Sign in";

const email = 'E-mail';
const emailHelperText = "Please enter your email here";
const password = 'Password';
const passwordHelperText = 'Please enter your password here';

const dontHaveAnAccount = "Don't Have An Account ?";
const signIn = "SignIn";
const signUp = "Signup";

const userName = "Full name";
const userNameHelper = "Please enter your full name here";

const createNewAccount = "Create new account";
const countryCode = "+92";

Color darkGreenColor = const Color(0xff006600);
Color lightGreenColor = const Color(0xff51f151);

final Map<String, List<String>> provinceDistricts = {
  'Khyber Pakhtunkhwa': [
    'Peshawar',
    'Swat',
    'Abbottabad',
    'Bajaur',
    'Bannu',
    'Battagram',
    'Buner',
    'Charsadda',
    'Chitral',
    'Dera Ismail Khan',
    'Hangu',
    'Haripur',
    'Haripur',
    'Karak',
    'Khar',
    'Kohat',
    'Lakki Marwat',
    'Lower Dir',
    'Lower Kohistan',
    'Malakand',
    'Mansehra',
    'Mardan',
    'Nowshera',
    'Shangla',
    'Swabi',
    'Tank',
    'Torghar',
    'Upper Dir',
    'Upper Kohistan',
  ],
  'Punjab': [
    'Lahore',
    'Faisalabad',
    'Rawalpindi',
    'Kasur',
    'Sheikhupura',
    'Nankana Sahib',
    'Gujrat',
    'Mandi Baha ud Din',
    'Hafizabad',
    'Wazirabad',
    'Gujranwala',
    'Norowal',
    'Sialkot',
    'Jhang',
    'Chiniot',
    'Toba Tek Singh',
    'Sargodha',
    'Khushab',
    'Mianwali',
    'Bhakkar',
    'Sahiwal',
    'Okara',
    'Pakpattan',
    'Multan',
    'Vehari',
    'Lodhran',
    'Khanewal',
    'Dera Ghazi Khan',
    'Rajanpur',
    'Taunsa Sharif',
    'Layyah',
    'Kot Addu',
    'Muzaffar Garh',
    'Jhelum',
    'Attock',
    'Murree',
    'Talagang',
    'Chakwal',
    'Bahawalpur',
    'Rahim Yar Khan',
    'Bahawalnagar'
  ],
  'Sindh': [
    'Karachi',
    'Hyderabad',
    'Sukkur',
    'Ghotki',
    'Khairpur',
    'Larkana',
    'Jacobabad',
    'Kashmore',
    'Qambar Shahdadkot',
    'Shikarpur',
    'Shaheed Benazirabad',
    'Naushahro Feroze',
    'Sanghar',
    'Mirpur Khas',
    'Umerkot',
    'Tharparkar',
    'Jamshoro',
    'Dadu',
    'Tando Allahyar',
    'Tando Muhammad Khan',
    'Matiari',
    'Badin',
    'Thatta',
    'Sujawal',
    'Karachi Central',
    'Karachi East',
    'Karachi South',
    'Karachi West',
    'Korangi',
    'Malir',
    'Keamari'
  ],
  "Balouchistan": [
    'Quetta',
    'Gwadar',
    'Khuzdar',
    'Awaran',
    'Barkhan',
    'Kachhi',
    'Chagai',
    'Chaman',
    'Dera Bhugti',
    'Duki',
    'Harnai',
    'Hub',
    'Jafarabad',
    'Jhal Magsi',
    'Kalat',
    'Kech',
    'Kharan',
    'Kohlu',
    'Lasbela',
    'Loralai',
    'Mastung',
    'Musakhel',
    'Nasirabad',
    'Nushki',
    'Qila Abdullah',
    'Qila Saifullah',
    'Panjgur',
    'Pishin',
    'Sherani',
    'Sibi',
    'Sohbatpur',
    'Surab',
    'Washuk',
    'Zhob',
    'Ziarat',
    'Usta Muhammad'
  ],
  'Azad Kashmir': [
    'Muzaffarabad',
    'Mirpur',
    'Kotli',
    'Bagh',
    'Bhimber',
    'Hattian Bala',
    'Haveli',
    'Neelum Valley',
    'Rawalakot',
    'Sudhanoti',
  ],
  'Gilgit Baltistan': [
    'Gilgit',
    'Skardu',
    'Hunza',
    'Ghanche',
    'Shigar',
    'Kharmang',
    'Roundu',
    'Ghizer',
    'Gupis–Yasin',
    'Nagar',
    'Astore',
    'Diamer',
    'Darel',
    'Tangir'
  ],
};
