import 'package:flutter/material.dart';
import '../models/service_category.dart';

class MockData {
  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'ac',
      name: 'AC Repair',
      icon: Icons.ac_unit,
      color: Color(0xFF2E90FA),
      startingPrice: 1500,
      imageUrl: 'https://images.pexels.com/photos/4489734/pexels-photo-4489734.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'plumbing',
      name: 'Plumbing',
      icon: Icons.plumbing,
      color: Color(0xFF00A651),
      startingPrice: 800,
      imageUrl: 'https://images.pexels.com/photos/8486972/pexels-photo-8486972.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'electrical',
      name: 'Electrical',
      icon: Icons.electric_bolt,
      color: Color(0xFFF79009),
      startingPrice: 1200,
      imageUrl: 'https://images.pexels.com/photos/8005368/pexels-photo-8005368.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'fan',
      name: 'Fan Repair',
      icon: Icons.wind_power,
      color: Color(0xFF7A5AF8),
      startingPrice: 600,
      imageUrl: 'https://images.pexels.com/photos/4078088/pexels-photo-4078088.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'fridge',
      name: 'Refrigerator',
      icon: Icons.kitchen,
      color: Color(0xFFF04438),
      startingPrice: 2500,
      imageUrl: 'https://images.pexels.com/photos/6996152/pexels-photo-6996152.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'washing',
      name: 'Washing Machine',
      icon: Icons.local_laundry_service,
      color: Color(0xFF06AED4),
      startingPrice: 1800,
      imageUrl: 'https://images.pexels.com/photos/4489749/pexels-photo-4489749.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'geyser',
      name: 'Geyser',
      icon: Icons.water_drop,
      color: Color(0xFFEE46BC),
      startingPrice: 2000,
      imageUrl: 'https://images.pexels.com/photos/4489749/pexels-photo-4489749.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
    ServiceCategory(
      id: 'carpentry',
      name: 'Carpentry',
      icon: Icons.handyman,
      color: Color(0xFF6172F3),
      startingPrice: 700,
      imageUrl: 'https://images.pexels.com/photos/5691622/pexels-photo-5691622.jpeg?auto=compress&cs=tinysrgb&w=600',
    ),
  ];

  static const List<String> popularSearches = [
    'AC leaking water',
    'Kitchen pipe broken',
    'Short circuit',
    'Fridge not cooling',
    'Fan not working',
  ];

  static const List<Map<String, dynamic>> recentJobs = [
    {'title': 'AC Leaking Water', 'category': 'AC Repair', 'price': 1500, 'status': 'Completed', 'worker': 'Ali AC Services', 'date': '2 days ago'},
    {'title': 'Kitchen Pipe Broken', 'category': 'Plumbing', 'price': 800, 'status': 'Completed', 'worker': 'Hassan Plumbers', 'date': '1 week ago'},
    {'title': 'Bedroom Short Circuit', 'category': 'Electrical', 'price': 1200, 'status': 'Cancelled', 'worker': 'Bilal Electrician', 'date': '2 weeks ago'},
  ];

  static const List<Map<String, dynamic>> workerFeed = [
    {'title': 'AC Leaking Water', 'category': 'AC Repair', 'price': 1500, 'distance': '2.3 km', 'area': 'Gulberg III', 'posted': '3 min ago'},
    {'title': 'Kitchen Pipe Broken', 'category': 'Plumbing', 'price': 800, 'distance': '1.1 km', 'area': 'DHA Phase 5', 'posted': '12 min ago'},
    {'title': 'Bedroom Short Circuit', 'category': 'Electrical', 'price': 1200, 'distance': '3.8 km', 'area': 'Johar Town', 'posted': '25 min ago'},
    {'title': 'Fridge Not Cooling', 'category': 'Refrigerator Repair', 'price': 2500, 'distance': '4.5 km', 'area': 'Model Town', 'posted': '1 hr ago'},
    {'title': 'Ceiling Fan Not Working', 'category': 'Fan Repair', 'price': 600, 'distance': '0.9 km', 'area': 'Iqbal Town', 'posted': '2 hr ago'},
  ];

  static const List<Map<String, dynamic>> myBookings = [
    {
      'title': 'AC Leaking Water',
      'category': 'AC Repair',
      'price': 1425,
      'status': 'Active',
      'worker': 'Ali AC Services',
      'date': 'Today, 3:45 PM',
      'address': 'House 234, Gulberg III, Lahore',
      'eta': '8 min away',
    },
    {
      'title': 'Kitchen Pipe Broken',
      'category': 'Plumbing',
      'price': 760,
      'status': 'Completed',
      'worker': 'Hassan Plumbers',
      'date': 'Oct 28, 11:20 AM',
      'address': 'House 234, Gulberg III, Lahore',
      'eta': 'Done',
    },
    {
      'title': 'Bedroom Short Circuit',
      'category': 'Electrical',
      'price': 1140,
      'status': 'Completed',
      'worker': 'Bilal Electrician',
      'date': 'Oct 22, 6:10 PM',
      'address': 'House 234, Gulberg III, Lahore',
      'eta': 'Done',
    },
    {
      'title': 'Fridge Not Cooling',
      'category': 'Refrigerator Repair',
      'price': 2375,
      'status': 'Cancelled',
      'worker': 'Usman Fridge Services',
      'date': 'Oct 15, 2:00 PM',
      'address': 'House 234, Gulberg III, Lahore',
      'eta': 'Cancelled',
    },
  ];
}